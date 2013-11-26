# coding: utf-8
require "awesome_print"

class ActionController::LogSubscriber
  alias :original_start_processing :start_processing

  def start_processing(event)
    base_params = event.payload[:params]
    if base_params && base_params.respond_to?(:ai)
      class << base_params
        alias :original_except :except

        def except(*keys)
          excepted = original_except(*keys)
          class << excepted
            def inspect
              ai
            end
          end
          expcepted
        end
      end
    end
    original_start_processing(event)
  end
end
