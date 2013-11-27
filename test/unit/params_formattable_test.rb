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
    if ActionController::Base.logger.errors.present?
      fail ActionController::Base.logger.errors.first
    else
      logs = ActionController::Base.logger.infos.map { |log| log.gsub(/\e\[(\d+;)*\d+m/, "") }
      assert_equal %(  Parameters: )           , logs[1]
      assert_equal %({)                        , logs[2]
      assert_equal %(    "foo" => "foo_value",), logs[3]
      assert_equal %(    "bar" => "bar_value") , logs[4]
      assert_equal %(})                        , logs[5]
    end
  end
end
