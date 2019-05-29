# frozen_string_literal: true

module Flog
  # PayloadValueShuntable enables to shunt value in payload
  module PayloadValueShuntable
    def shunt_payload_value(payload, key, temp_value, &block)
      return unless block

      if payload.key?(key)
        shunt_if_key_already_exists(payload, key, temp_value, block)
      else
        shunt_if_key_not_exist(payload, key, temp_value, block)
      end
    end

    def shunt_if_key_already_exists(payload, key, temp_value, block)
      base_value = payload[key]
      begin
        payload[key] = temp_value
        block.call
      ensure
        payload[key] = base_value
      end
    end

    def shunt_if_key_not_exist(payload, key, temp_value, block)
      payload[key] = temp_value
      block.call
    ensure
      payload.delete(key)
    end
  end
end
