# coding: utf-8
require "rails"
require "test_helper"

class StatusTest < ActiveSupport::TestCase
  def setup
    @test_root = Pathname.new(File.expand_path(File.dirname(__FILE__) + "../../"))
  end

  def teardown
    delete_switch_file
    delete_sql_switch_file
    delete_params_switch_file
  end

  def test_enabled_is_true_when_switch_file_does_not_exist
    delete_switch_file
    assert Flog::Status.enabled?
  end

  def test_enabled_is_false_when_switch_file_exists
    Rails.expects(:root).at_most(2).returns(@test_root)
    create_switch_file
    assert_equal false, Flog::Status.enabled?
  end

  def test_enabled_is_true_when_error_is_raised_in_process
    Rails.expects(:root).returns(nil) # For raise NoMethodError
    create_switch_file
    assert Flog::Status.enabled?
  end

  def test_sql_formattable_is_true_when_enable_and_sql_switch_file_does_not_exist
    Rails.expects(:root).at_most(2).returns(@test_root)
    delete_switch_file
    delete_sql_switch_file
    assert Flog::Status.sql_formattable?
  end

  def test_sql_formattable_is_false_when_enable_and_sql_switch_file_exists
    Rails.expects(:root).at_most(2).returns(@test_root)
    delete_switch_file
    create_sql_switch_file
    assert_equal false, Flog::Status.sql_formattable?
  end

  def test_sql_formattable_is_false_when_disable_and_sql_switch_file_not_exist
    Rails.expects(:root).at_most(2).returns(@test_root)
    create_switch_file
    delete_sql_switch_file
    assert_equal false, Flog::Status.sql_formattable?
  end

  def test_sql_formattable_is_true_when_error_is_raised_in_process
    Rails.expects(:root).at_most(2).returns(nil) # For raise NoMethodError
    create_sql_switch_file
    assert Flog::Status.sql_formattable?
  end

  def test_sql_formattable_is_false_when_disable_and_sql_switch_file_exists
    Rails.expects(:root).at_most(2).returns(@test_root)
    create_switch_file
    create_sql_switch_file
    assert_equal false, Flog::Status.sql_formattable?
  end

  def test_params_formattable_is_true_when_enable_and_params_switch_file_does_not_exist
    Rails.expects(:root).at_most(2).returns(@test_root)
    delete_switch_file
    delete_params_switch_file
    assert Flog::Status.params_formattable?
  end

  def test_params_formattable_is_false_when_enable_and_params_switch_file_exists
    Rails.expects(:root).at_most(2).returns(@test_root)
    delete_switch_file
    create_params_switch_file
    assert_equal false, Flog::Status.params_formattable?
  end

  def test_params_formattable_is_false_when_disable_and_params_switch_file_not_exist
    Rails.expects(:root).at_most(2).returns(@test_root)
    create_switch_file
    delete_params_switch_file
    assert_equal false, Flog::Status.params_formattable?
  end

  def test_params_formattable_is_false_when_disable_and_params_switch_file_exists
    Rails.expects(:root).at_most(2).returns(@test_root)
    create_switch_file
    create_params_switch_file
    assert_equal false, Flog::Status.params_formattable?
  end

  def test_params_formattable_is_true_when_error_is_raised_in_process
    Rails.expects(:root).at_most(2).returns(nil) # For raise NoMethodError
    create_params_switch_file
    assert Flog::Status.params_formattable?
  end

  private
  def create_switch_file
    create_file(@test_root.join("tmp", Flog::Status::SWITCH_FILE_NAME))
  end

  def delete_switch_file
    delete_file(@test_root.join("tmp", Flog::Status::SWITCH_FILE_NAME))
  end

  def create_sql_switch_file
    create_file(@test_root.join("tmp", Flog::Status::SQL_SWITCH_FILE_NAME))
  end

  def delete_sql_switch_file
    delete_file(@test_root.join("tmp", Flog::Status::SQL_SWITCH_FILE_NAME))
  end

  def create_params_switch_file
    create_file(@test_root.join("tmp", Flog::Status::PARAMS_SWITCH_FILE_NAME))
  end

  def delete_params_switch_file
    delete_file(@test_root.join("tmp", Flog::Status::PARAMS_SWITCH_FILE_NAME))
  end

  def create_file(file_path)
    File.open(file_path, "w").close
  end

  def delete_file(file_path)
    if File.exist?(file_path)
      File.delete(file_path)
    end
  end
end
