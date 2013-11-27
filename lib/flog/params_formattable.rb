# coding: utf-8
require "action_controller/log_subscriber"
require "awesome_print"
require "flog/payload_value_shuntable"

class ActionController::LogSubscriber
  include PayloadValueShuntable

  alias :original_start_processing :start_processing

  def start_processing(event)
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
            "\n#{ai}"
          end
        end
        excepted
      end
    end
    replaced
  end
end
