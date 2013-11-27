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
  end

  def teardown
    ActiveRecord::Base.logger = @old_logger
  end

  def test_sql_is_formatted
    Book.where(category: "comics").to_a
    if ActiveRecord::Base.logger.errors.present?
      fail ActiveRecord::Base.logger.errors.first
    else
      logs = ActiveRecord::Base.logger.debugs.map { |log| log.gsub("\t", "    ") }
      assert_equal %{    SELECT}                             , logs[1]
      assert_equal %{        "books" . *}                    , logs[2]
      assert_equal %{    FROM}                               , logs[3]
      assert_equal %{        "books"}                        , logs[4]
      assert_equal %{    WHERE}                              , logs[5]
      assert_equal %{        "books" . "category" = 'comics'}, logs[6]
    end
  end
end
