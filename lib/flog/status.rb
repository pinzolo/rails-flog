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

    def self.switch_file_base_path
      if Rails.root && Rails.root.exist?
        Rails.root
      else
        Pathname.new(File.expand_path(File.dirname(__FILE__) + "../../"))
      end
    end

    def self.switch_file_dir_path
      switch_file_base_path.join("tmp")
    end

    private
    def self.switch_file_exists?(file_name)
      switch_file_dir_path.join(file_name).exist?
    end
  end
end
