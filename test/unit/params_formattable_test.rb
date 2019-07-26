# frozen_string_literal: true

require 'action_controller'
require 'test_helper'

class TestController < ActionController::Base
  def initialize(routes)
    @routes = routes
  end

  def _routes
    @routes
  end

  def show
    head :not_found
  end
end

module ParamsFormattableTestHelper
  def setup
    # default configuration
    Flog.configure do |config|
      config.params_key_count_threshold = 1
      config.force_on_nested_params = true
    end

    @old_logger = ActionController::Base.logger
    ActiveSupport::LogSubscriber.colorize_logging = false
    setup_routes
    super
    ActionController::Base.logger = TestLogger.new
  end

  def teardown
    super
    ActionController::Base.logger = @old_logger
  end

  def setup_routes
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'test/show', to: 'test#show'
    end
    @controller = TestController.new(@routes)
  end

  def assert_logger(&block)
    raise ActionController::Base.logger.errors.first if ActionController::Base.logger.errors.present?

    block.call(ActionController::Base.logger)
  end

  def assert_include(log, *expected_includees)
    expected_includees.each do |e|
      assert log.include?(e)
    end
  end

  def assert_hash(hash)
    assert_equal hash['foo'], 'foo_value'
    assert_equal hash['bar']['prop'], 'prop_value'
    assert_equal hash['bar']['attr'], 'attr_value'
  end

  def get_show(params)
    if Gem::Version.new(Rails.version) >= Gem::Version.new('5.0.0')
      get :show, params: params
    else
      get :show, params
    end
  end

  def hash_from_logs(logs, start, finish)
    eval(start.upto(finish).reduce('') { |s, n| s + logs[n] })
  end
end

class ParamsFormattableTest < ActionController::TestCase
  include ParamsFormattableTestHelper

  def test_parameters_log_is_formatted
    get_show foo: 'foo_value', bar: { prop: 'prop_value', attr: 'attr_value' }
    assert_logger do |logger|
      logs = logger.infos.map { |log| remove_color_seq(log) }
      assert_equal '  Parameters: ', logs[1]
      hash = hash_from_logs(logs, 2, 8)
      assert_hash hash
    end
  end

  def test_colorized_on_colorize_loggin_is_true
    ActiveSupport::LogSubscriber.colorize_logging = true
    get_show foo: 'foo_value', bar: 'bar_value'
    assert_logger do |logger|
      assert match_color_seq(logger.infos.join)
    end
  end

  def test_not_colorized_on_colorize_loggin_is_false
    Flog::Status.stub(:enabled?, true) do
      get_show foo: 'foo_value', bar: 'bar_value'
      assert_logger do |logger|
        assert_nil match_color_seq(logger.infos.join)
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_enabled_is_false
    Flog::Status.stub(:enabled?, false) do
      get_show foo: 'foo_value', bar: 'bar_value'
      assert_logger do |logger|
        assert_include logger.infos[1], 'Parameters: {', %("foo"=>"foo_value"), %("bar"=>"bar_value")
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_params_formattable_is_false
    Flog::Status.stub(:params_formattable?, false) do
      get_show foo: 'foo_value', bar: 'bar_value'
      assert_logger do |logger|
        assert_include logger.infos[1], 'Parameters: {', %("foo"=>"foo_value"), %("bar"=>"bar_value")
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_key_of_parameters_count_equals_to_configured_threshold
    Flog.configure do |config|
      config.params_key_count_threshold = 2
    end
    get_show foo: 'foo_value', bar: 'bar_value'
    assert_logger do |logger|
      assert_include logger.infos[1], 'Parameters: {', %("foo"=>"foo_value"), %("bar"=>"bar_value")
    end
  end

  def test_parameters_log_is_not_formatted_when_key_of_parameters_count_is_under_configured_threshold
    Flog.configure do |config|
      config.params_key_count_threshold = 3
    end
    get_show foo: 'foo_value', bar: 'bar_value'
    assert_logger do |logger|
      assert_include logger.infos[1], 'Parameters: {', %("foo"=>"foo_value"), %("bar"=>"bar_value")
    end
  end

  # rubocop:disable Metrics/LineLength
  def test_parameters_log_is_formatted_when_key_of_parameters_count_is_under_configured_threshold_but_force_on_nested_params_configuration_is_true
    Flog.configure do |config|
      config.params_key_count_threshold = 3
    end
    get_show foo: 'foo_value', bar: { prop: 'prop_value', attr: 'attr_value' }
    assert_logger do |logger|
      logs = logger.infos.map { |log| remove_color_seq(log) }
      assert_equal '  Parameters: ', logs[1]
      hash = hash_from_logs(logs, 2, 8)
      assert_hash hash
    end
  end
  # rubocop:enable Metrics/LineLength

  def test_parameters_log_is_not_formatted_when_ignore_params_configuration_is_true
    Flog.configure do |config|
      config.ignore_params = true
    end
    get_show foo: 'foo_value', bar: 'bar_value'
    assert_logger do |logger|
      assert_include logger.infos[1], 'Parameters: {', %("foo"=>"foo_value"), %("bar"=>"bar_value")
    end
  end
end
