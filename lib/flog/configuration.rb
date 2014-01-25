# coding: utf-8
module Flog
  class Configuration
    attr_writer :ignore_cached_query, :force_on_nested_params
    attr_accessor :query_duration_threshold, :params_key_count_threshold

    def initialize
      @ignore_cached_query = true
      @query_duration_threshold = 0.0
      @params_key_count_threshold = 1
      @force_on_nested_params = true
    end

    def ignore_cached_query?
      !!@ignore_cached_query
    end

    def force_on_nested_params?
      !!@force_on_nested_params
    end
  end

  def self.config
    @@config ||= Flog::Configuration.new
  end

  def self.configure
    yield(config) if block_given?
  end
end
