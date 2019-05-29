# frozen_string_literal: true

require 'rails'

module Flog
  # Status returns checke result of switch files
  class Status
    SWITCH_FILE_NAME = 'no-flog.txt'
    SQL_SWITCH_FILE_NAME = 'no-flog-sql.txt'
    PARAMS_SWITCH_FILE_NAME = 'no-flog-params.txt'
    class << self
      def enabled?
        !switch_file_exists?(SWITCH_FILE_NAME)
      rescue StandardError
        true
      end

      def sql_formattable?
        enabled? && !switch_file_exists?(SQL_SWITCH_FILE_NAME)
      rescue StandardError
        true
      end

      def params_formattable?
        enabled? && !switch_file_exists?(PARAMS_SWITCH_FILE_NAME)
      rescue StandardError
        true
      end

      def switch_file_base_path
        if Rails.root&.exist?
          Rails.root
        else
          Pathname.new(File.expand_path(File.dirname(__FILE__) + '../../'))
        end
      end

      def switch_file_dir_path
        switch_file_base_path.join('tmp')
      end

      private

      def switch_file_exists?(file_name)
        switch_file_dir_path.join(file_name).exist?
      end
    end
  end
end
