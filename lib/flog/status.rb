# coding: utf-8
require "rails"

module Flog
  class Status
    SWITCH_FILE_NAME = "no-flog.txt"

    def self.enabled?
      !File.exist?(Rails.root.join("tmp", SWITCH_FILE_NAME).to_s)
    rescue
      true
    end
  end
end
