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
    # default configuration
    Flog.configure do |config|
      config.ignore_cached_query = true
      config.query_duration_threshold = 0.0
    end

    @old_logger = ActiveRecord::Base.logger
    ActiveSupport::LogSubscriber.colorize_logging = false
    ActiveRecord::Base.logger = TestLogger.new
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
    Flog::Status.stubs(:enabled?).returns(false)
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert_one_line_sql logger.debugs.first
    end
  end

  def test_sql_is_not_formatted_when_sql_formattable_is_false
    Flog::Status.stubs(:sql_formattable?).returns(false)
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert_one_line_sql logger.debugs.first
    end
  end

  def test_sql_is_not_formatted_on_cached_query
    Book.cache do
      Book.where(category: "comics").to_a
      Book.where(category: "comics").to_a
    end
    assert_logger do |logger|
      logs = logger.debugs.map { |log| log.gsub("\t", "    ") }
      logs.each do |log|
        assert_one_line_sql log if log.include?("CACHE")
      end
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
      logs.each do |log|
        assert_equal log.include?("SELECT"), false if log.include?("CACHE")
      end
    end
  end

  def test_sql_is_not_formatted_when_duration_is_under_threshold
    Flog.configure do |config|
      config.query_duration_threshold = 100.0
    end
    Book.where(category: "comics").to_a
    assert_logger do |logger|
      assert_one_line_sql logger.debugs.first
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

  def assert_one_line_sql(sql)
    assert sql.include?("SELECT")
    assert sql.include?("FROM")
    assert sql.include?("WHERE")
  end
end
