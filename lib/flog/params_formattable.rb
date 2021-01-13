# frozen_string_literal: true

require 'action_controller/log_subscriber'
require 'amazing_print'
require 'flog/payload_value_shuntable'

module Flog
  # Overrides `inspect` method for formatting itself
  module ParamsInspectOverridable
    def inspect
      "\n#{ai(plain: !ActionController::LogSubscriber.colorize_logging)}"
    end
  end

  # Overrides `except` method for formatting ecepted params.
  module ParamsExceptOverridable
    def except(*keys)
      excepted = super(*keys)
      excepted.singleton_class.prepend(ParamsInspectOverridable)
      excepted
    end
  end

  # ParamsFormattable enables to format request parameters in log.
  module ParamsFormattable
    include Flog::PayloadValueShuntable
    def start_processing(event)
      return super(event) unless formattable?(event)

      replaced = replace_params(event.payload[:params])

      shunt_payload_value(event.payload, :params, replaced) do
        super(event)
      end
    end

    private

    def replace_params(params)
      return params if params.empty? || !params.respond_to?(:ai)

      replaced = params.dup
      replaced.singleton_class.prepend(ParamsExceptOverridable)
      replaced
    end

    def formattable?(event)
      return false if Flog.config.ignore_params?
      return false unless Flog::Status.params_formattable?

      return true if force_format_by_nested_params?(event)

      key_count_over?(event)
    end

    def force_format_by_nested_params?(event)
      return false unless Flog.config.force_on_nested_params?

      event.payload[:params].values.any? { |value| value.is_a?(Hash) }
    end

    def key_count_over?(event)
      threshold = Flog.config.params_key_count_threshold.to_i
      params = event.payload[:params].except(*ActionController::LogSubscriber::INTERNAL_PARAMS)
      params.keys.size > threshold
    end
  end
end

ActionController::LogSubscriber.prepend(Flog::ParamsFormattable)
