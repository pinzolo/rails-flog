# coding: utf-8
module Flog
  module PayloadValueShuntable
    def shunt_payload_value(payload, key, temp_value, &block)
      return unless block

      key_exists = payload.key?(key)
      base_value = payload[key]
      begin
        payload[key] = temp_value
        block.call
      ensure
        if key_exists
          payload[key] = base_value
        else
          payload.delete(key)
        end
      end
    end
  end
end
