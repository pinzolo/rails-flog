module Flog
  class Configuration
    attr_writer :ignore_cached_query, :force_on_nested_params
    attr_accessor :query_duration_threshold, :params_key_count_threshold, :sql_indent

    def initialize
      @ignore_cached_query = true
      @query_duration_threshold = 0.0
      @params_key_count_threshold = 1
      @force_on_nested_params = true
      @sql_indent = "\t"
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
    cfg = Flog::Configuration.new
    yield(cfg) if block_given?
    @@config = cfg
  end
end
