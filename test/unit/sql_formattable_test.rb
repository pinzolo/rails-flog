# frozen_string_literal: true

require 'active_record'
require 'test_helper'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

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
    Book.where(category: 'comics').to_a
    assert_logger do |logger|
      assert_equal %{\tSELECT}       , logger.debugs[1]
      assert_equal %{\t\t"books" . *}, logger.debugs[2]
      assert_equal %{\tFROM}         , logger.debugs[3]
      assert_equal %{\t\t"books"}    , logger.debugs[4]
      assert_equal %{\tWHERE}        , logger.debugs[5]
      assert logger.debugs[6].start_with?(%{\t\t"books"."category" = })
    end
  end

  def test_colorized_on_colorize_loggin_is_true
    ActiveSupport::LogSubscriber.colorize_logging = true
    Book.where(category: 'comics').to_a
    assert_logger do |logger|
      assert match_color_seq(logger.debugs.join())
    end
  end

  def test_not_colorized_on_colorize_loggin_is_false
    Book.where(category: 'comics').to_a
    assert_logger do |logger|
      assert_nil match_color_seq(logger.debugs.join())
    end
  end

  def test_sql_is_not_formatted_when_enabled_is_false
    Flog::Status.stub(:enabled?, false) do
      Book.where(category: 'comics').to_a
      assert_logger do |logger|
        assert_one_line_sql logger.debugs.first
      end
    end
  end

  def test_sql_is_not_formatted_when_sql_formattable_is_false
    Flog::Status.stub(:sql_formattable?, false) do
      Book.where(category: 'comics').to_a
      assert_logger do |logger|
        assert_one_line_sql logger.debugs.first
      end
    end
  end

  def test_sql_is_not_formatted_on_cached_query
    Book.cache do
      Book.where(category: 'comics').to_a
      Book.where(category: 'comics').to_a
    end
    assert_logger do |logger|
      logger.debugs.each do |log|
        assert_one_line_sql log if log.include?('CACHE')
      end
    end
  end

  def test_sql_is_formatted_on_cached_query_when_ignore_cached_query_configration_is_false
    Flog.configure do |config|
      config.ignore_cached_query = false
    end
    Book.cache do
      Book.where(category: 'comics').to_a
      Book.where(category: 'comics').to_a
    end
    assert_logger do |logger|
      logger.debugs.each do |log|
        assert_equal log.include?('SELECT'), false if log.include?('CACHE')
      end
    end
  end

  def test_sql_is_not_formatted_when_duration_is_under_threshold
    Flog.configure do |config|
      config.query_duration_threshold = 100.0
    end
    Book.where(category: 'comics').to_a
    assert_logger do |logger|
      assert_one_line_sql logger.debugs.first
    end
  end

  def test_2space_indent
    Flog.configure do |config|
      config.sql_indent = '  '
    end
    Book.where(category: 'comics').to_a
    assert_logger do |logger|
      assert_equal %{  SELECT}       , logger.debugs[1]
      assert_equal %{    "books" . *}, logger.debugs[2]
      assert_equal %{  FROM}         , logger.debugs[3]
      assert_equal %{    "books"}    , logger.debugs[4]
      assert_equal %{  WHERE}        , logger.debugs[5]
      assert logger.debugs[6].start_with?(%{    "books"."category" = })
    end
  end

  def test_default_in_values_num
    Book.where(id: (1..10).to_a).to_a
    assert_logger do |logger|
      assert_equal %{\tSELECT}               , logger.debugs[1]
      assert_equal %{\t\t"books" . *}        , logger.debugs[2]
      assert_equal %{\tFROM}                 , logger.debugs[3]
      assert_equal %{\t\t"books"}            , logger.debugs[4]
      assert_equal %{\tWHERE}                , logger.debugs[5]
      assert_equal %{\t\t"books"."id" IN (}, logger.debugs[6]
      (8..16).each do |l|
        assert_equal 1, logger.debugs[l].count(',')
      end
      assert logger.debugs[17].start_with?(%{\t\t)})
    end
  end

  def test_in_values_num_set
    Flog.configure do |config|
      config.sql_in_values_num = 5
    end
    Book.where(id: (1..10).to_a).to_a
    assert_logger do |logger|
      assert_equal %{\tSELECT}               , logger.debugs[1]
      assert_equal %{\t\t"books" . *}        , logger.debugs[2]
      assert_equal %{\tFROM}                 , logger.debugs[3]
      assert_equal %{\t\t"books"}            , logger.debugs[4]
      assert_equal %{\tWHERE}                , logger.debugs[5]
      assert_equal %{\t\t"books"."id" IN (}, logger.debugs[6]
      assert_equal 4, logger.debugs[7].count(',')
      assert_equal 5, logger.debugs[8].count(',')
      assert logger.debugs[9].start_with?(%{\t\t)})
    end
  end

  def test_oneline_in_values
    Flog.configure do |config|
      config.sql_in_values_num = Flog::ONELINE_IN_VALUES_NUM
    end
    Book.where(id: (1..10).to_a).to_a
    assert_logger do |logger|
      assert_equal %{\tSELECT}               , logger.debugs[1]
      assert_equal %{\t\t"books" . *}        , logger.debugs[2]
      assert_equal %{\tFROM}                 , logger.debugs[3]
      assert_equal %{\t\t"books"}            , logger.debugs[4]
      assert_equal %{\tWHERE}                , logger.debugs[5]
      assert_equal %{\t\t"books"."id" IN (}, logger.debugs[6]
      assert_equal 9, logger.debugs[7].count(',')
      assert logger.debugs[8].start_with?(%{\t\t)})
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
    assert sql.include?('SELECT')
    assert sql.include?('FROM')
    assert sql.include?('WHERE')
  end
end
