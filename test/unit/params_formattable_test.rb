# coding: utf-8
require "action_controller"
require "test_helper"

class TestController < ActionController::Base
  def initialize(routes)
    @routes = routes
  end

  def _routes
    @routes
  end

  def show
    render nothing: true
  end
end

class ParamsFormattableTest < ActionController::TestCase
  def setup
    @old_logger = ActionController::Base.logger
    ActiveSupport::LogSubscriber.colorize_logging = false
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
        get "test/show", to: "test#show"
      end
    @controller = TestController.new(@routes)
    super
    ActionController::Base.logger = TestLogger.new
  end

  def teardown
    super
    ActionController::Base.logger = @old_logger
  end

  def test_parameters_log_is_formatted
    get :show, foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      logs = logger.infos.map { |log| log.gsub(/\e\[(\d+;)*\d+m/, "") }
      assert_equal %(  Parameters: )           , logs[1]
      assert_equal %({)                        , logs[2]
      assert_equal %(    "foo" => "foo_value",), logs[3]
      assert_equal %(    "bar" => "bar_value") , logs[4]
      assert_equal %(})                        , logs[5]
    end
  end

  def test_colorized_on_colorize_loggin_is_true
    ActiveSupport::LogSubscriber.colorize_logging = true
    get :show, foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert /\e\[(\d+;)*\d+m/.match(logger.infos.join())
    end
  end

  def test_not_colorized_on_colorize_loggin_is_false
    get :show, foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert_nil /\e\[(\d+;)*\d+m/.match(logger.infos.join())
    end
  end

  def test_parameters_log_is_not_formatted_when_enabled_is_false
    Flog::Status.expects(:enabled?).returns(false)
    get :show, foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert logger.infos[1].include?(%(Parameters: {"foo"=>"foo_value", "bar"=>"bar_value"}))
    end
  end

  private
  def assert_logger(&block)
    if ActionController::Base.logger.errors.present?
      fail ActionController::Base.logger.errors.first
    else
      block.call(ActionController::Base.logger)
    end
  end
end
