# coding: utf-8
require "rails"

module Flog
  class Status
    SWITCH_FILE_NAME = "no-flog.txt"
    SQL_SWITCH_FILE_NAME = "no-flog-sql.txt"
    PARAMS_SWITCH_FILE_NAME = "no-flog-params.txt"

    def self.enabled?
      !switch_file_exists?(SWITCH_FILE_NAME)
    rescue
      true
    end

    def self.sql_formattable?
      enabled? && !switch_file_exists?(SQL_SWITCH_FILE_NAME)
    rescue
      true
    end

    def self.params_formattable?
      enabled? && !switch_file_exists?(PARAMS_SWITCH_FILE_NAME)
    rescue
      true
    end

    private
    def self.switch_file_exists?(file_name)
      File.exist?(Rails.root.join("tmp", file_name).to_s)
    end
  end
end
