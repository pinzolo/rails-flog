# frozen_string_literal: true

require 'anbt-sql-formatter/rule'

# Flog is root module of this gem
module Flog
  ONELINE_IN_VALUES_NUM = ::AnbtSql::Rule::ONELINE_IN_VALUES_NUM

  # Configuration of this gem.
  # Call `configure` to setup.
  class Configuration
    attr_writer :ignore_cached_query, :force_on_nested_params, :ignore_query, :ignore_params
    attr_accessor :query_duration_threshold, :params_key_count_threshold, :sql_indent, :sql_in_values_num

    def initialize
      @ignore_cached_query = true
      @query_duration_threshold = 0.0
      @params_key_count_threshold = 1
      @force_on_nested_params = true
      @sql_indent = "\t"
      @sql_in_values_num = 1
      @ignore_query = false
      @ignore_params = false
    end

    def ignore_cached_query?
      !!@ignore_cached_query || @ignore_query
    end

    def force_on_nested_params?
      !!@force_on_nested_params
    end

    def ignore_query?
      !!@ignore_query
    end

    def ignore_params?
      !!@ignore_params
    end
  end

  class << self
    def config
      @config ||= Flog::Configuration.new
    end

    def configure
      cfg = Flog::Configuration.new
      yield(cfg) if block_given?
      @config = cfg
    end
  end
end
