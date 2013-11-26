# coding: utf-8
module PayloadValueShuntable
  def shunt_payload_value(payload, key, temp_value, &block)
    base_value = payload[key]
    begin
      payload[key] = temp_value
      block.call
    ensure
      payload[key] = base_value
    end
  end
end
