# coding: utf-8
require "action_controller/log_subscriber"
require "awesome_print"
require "flog/payload_value_shuntable"
require "flog/status"

class ActionController::LogSubscriber
  include Flog::PayloadValueShuntable

  alias :original_start_processing :start_processing

  def start_processing(event)
    return original_start_processing(event) unless Flog::Status.enabled?

    replaced = replace_params(event.payload[:params])

    shunt_payload_value(event.payload, :params, replaced) do
      original_start_processing(event)
    end
  end

  private
  def replace_params(params)
    return params if params.empty? || !params.respond_to?(:ai)

    replaced = params.dup
    class << replaced
      alias :original_except :except

      def except(*keys)
        excepted = original_except(*keys)
        class << excepted
          def inspect
            "\n#{ai(plain: !ActionController::LogSubscriber.colorize_logging)}"
          end
        end
        excepted
      end
    end
    replaced
  end
end
