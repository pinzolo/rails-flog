# coding: utf-8
require "active_record"
require "test_helper"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define version: 0 do
  create_table :books, force: true do |t|
    t.string :name
    t.string :category
  end
end

class Book < ActiveRecord::Base; end

class SqlFormattableTest < ActiveSupport::TestCase
  def setup
    @old_logger = ActiveRecord::Base.logger
    ActiveSupport::LogSubscriber.colorize_logging = false
    ActiveRecord::Base.logger = TestLogger.new
    # default configuration
    Flog.configure do |config|
      config.ignore_cached_query = true
    end
  end

  def teardown
    ActiveRecord::Base.logger = @old_logger
  end

  def test_sql_is_formatted
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      logs = logger.debugs.map { |log| log.gsub("\t", "    ") }
      assert_equal %{    SELECT}                             , logs[1]
      assert_equal %{        "books" . *}                    , logs[2]
      assert_equal %{    FROM}                               , logs[3]
      assert_equal %{        "books"}                        , logs[4]
      assert_equal %{    WHERE}                              , logs[5]
      assert_equal %{        "books" . "category" = 'comics'}, logs[6]
    end
  end

  def test_colorized_on_colorize_loggin_is_true
    ActiveSupport::LogSubscriber.colorize_logging = true
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert /\e\[(\d+;)*\d+m/.match(logger.debugs.join())
    end
  end

  def test_not_colorized_on_colorize_loggin_is_false
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert_nil /\e\[(\d+;)*\d+m/.match(logger.debugs.join())
    end
  end

  def test_sql_is_not_formatted_when_enabled_is_false
    Flog::Status.expects(:enabled?).returns(false)
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert logger.debugs.first.include?(%(SELECT "books".* FROM "books" WHERE "books"."category" = 'comics'))
    end
  end

  def test_sql_is_not_formatted_when_sql_formattable_is_false
    Flog::Status.expects(:sql_formattable?).returns(false)
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert logger.debugs.first.include?(%(SELECT "books".* FROM "books" WHERE "books"."category" = 'comics'))
    end
  end

  def test_sql_is_not_formatted_on_cached_query
    Book.cache do
      Book.where(category: "comics").to_a
      Book.where(category: "comics").to_a
    end
    assert_logger do |logger|
      logs = logger.debugs.map { |log| log.gsub("\t", "    ") }
      assert_equal %{    SELECT}                             , logs[1]
      assert_equal %{        "books" . *}                    , logs[2]
      assert_equal %{    FROM}                               , logs[3]
      assert_equal %{        "books"}                        , logs[4]
      assert_equal %{    WHERE}                              , logs[5]
      assert_equal %{        "books" . "category" = 'comics'}, logs[6]
      assert logs[7].include?(%(SELECT "books".* FROM "books" WHERE "books"."category" = 'comics'))
    end
  end

  def test_sql_is_formatted_on_cached_query_when_ignore_cached_query_configration_is_false
    Flog.configure do |config|
      config.ignore_cached_query = false
    end
    Book.cache do
      Book.where(category: "comics").to_a
      Book.where(category: "comics").to_a
    end
    assert_logger do |logger|
      logs = logger.debugs.map { |log| log.gsub("\t", "    ") }
      assert_equal %{    SELECT}                             , logs[1]
      assert_equal %{        "books" . *}                    , logs[2]
      assert_equal %{    FROM}                               , logs[3]
      assert_equal %{        "books"}                        , logs[4]
      assert_equal %{    WHERE}                              , logs[5]
      assert_equal %{        "books" . "category" = 'comics'}, logs[6]
      assert_equal %{    SELECT}                             , logs[8]
      assert_equal %{        "books" . *}                    , logs[9]
      assert_equal %{    FROM}                               , logs[10]
      assert_equal %{        "books"}                        , logs[11]
      assert_equal %{    WHERE}                              , logs[12]
      assert_equal %{        "books" . "category" = 'comics'}, logs[13]
    end
  end

  private
  def assert_logger(&block)
    if ActiveRecord::Base.logger.errors.present?
      fail ActiveRecord::Base.logger.errors.first
    else
      block.call(ActiveRecord::Base.logger)
    end
  end
end
