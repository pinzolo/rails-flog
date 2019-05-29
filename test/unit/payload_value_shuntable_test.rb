# frozen_string_literal: true

require 'test_helper'

class TestClass
  include Flog::PayloadValueShuntable
end

class PayloadValueShuntableTest < ActiveSupport::TestCase
  def setup
    @tester = TestClass.new
    @payload = { foo: 'foo_value', bar: 'bar_value' }
  end

  def test_shunt_payload_value
    @tester.shunt_payload_value(@payload, :foo, 'new_value') do
      assert_equal 'new_value', @payload[:foo]
    end
  end

  def test_value_of_other_key_is_not_changed
    @tester.shunt_payload_value(@payload, :foo, 'new_value') do
      assert_equal 'bar_value', @payload[:bar]
    end
  end

  def test_restoration
    @tester.shunt_payload_value(@payload, :foo, 'new_value') do
      assert_equal 'new_value', @payload[:foo]
    end
    assert_equal 'foo_value', @payload[:foo]
  end

  def test_ensure_restoration_on_error_raised_in_block
    error_raised = false
    begin
      @tester.shunt_payload_value(@payload, :foo, 'new_value') do
        raise 'error'
      end
    rescue StandardError
      error_raised = true
    end
    assert error_raised
    assert_equal 'foo_value', @payload[:foo]
  end

  def test_without_block
    @tester.shunt_payload_value(@payload, :foo, 'new_value')
    assert_equal 'foo_value', @payload[:foo]
  end

  def test_key_removed_when_give_not_exist_key
    @tester.shunt_payload_value(@payload, :baz, 'new_value') do
      assert_equal 'new_value', @payload[:baz]
    end
    assert_equal false, @payload.key?(:baz)
  end
end
