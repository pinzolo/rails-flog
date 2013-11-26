# coding: utf-8
require "action_controller/log_subscriber"
require "awesome_print"

class ActionController::LogSubscriber
  alias :original_start_processing :start_processing

  def start_processing(event)
    raw_params = event.payload[:params]
    event.payload[:params] = replace_params(raw_params) if raw_params
    original_start_processing(event)
    # restore
    event.payload[:params] = raw_params
  end

  private
  def replace_params(params)
    return params unless params.respond_to?(:ai)

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
