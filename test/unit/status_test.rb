# coding: utf-8
require "rails"

class StatusTest < ActiveSupport::TestCase
  def setup
    @test_root = Pathname.new(File.expand_path(File.dirname(__FILE__) + "../../"))
    @switch_file_path = @test_root.join("tmp", Flog::Status::SWITCH_FILE_NAME)
  end

  def teardown
    delete_switch_file
  end

  def test_enabled_is_true_when_switch_file_does_not_exist
    delete_switch_file
    assert Flog::Status.enabled?
  end

  def test_enabled_is_false_when_switch_file_exists
    Rails.expects(:root).returns(@test_root)
    create_switch_file
    assert_equal false, Flog::Status.enabled?
  end

  def test_enabled_is_true_when_error_is_raised_in_process
    Rails.expects(:root).returns(nil) # For raise NoMethodError
    create_switch_file
    assert Flog::Status.enabled?
  end

  private
  def create_switch_file
    File.open(@switch_file_path, "w").close
  end

  def delete_switch_file
    if File.exist?(@switch_file_path)
      File.delete(@switch_file_path)
    end
  end
end
