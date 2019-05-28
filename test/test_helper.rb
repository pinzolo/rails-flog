# frozen_string_literal: true

require 'coveralls'
require 'simplecov'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter '/test/'
  add_filter '/bundle/'
end

require 'flog'
require 'minitest/autorun'

unless defined?(TestLogger)
  class TestLogger
    attr_accessor :debugs, :infos, :errors

    def initialize
      @debugs = []
      @infos = []
      @errors = []
    end

    def debug?
      true
    end

    def info?
      true
    end

    def debug(message)
      @debugs += message.split("\n") if message
    end

    def info(message)
      @infos += message.split("\n") if message
    end

    def error(message)
      @errors += message.split("\n") if message
    end
  end
end

unless defined?(COLOR_SEQ_REGEX)
  COLOR_SEQ_REGEX = /\e\[(\d+;)*\d+m/.freeze

  def remove_color_seq(log)
    log.gsub(COLOR_SEQ_REGEX, '')
  end

  def match_color_seq(log)
    COLOR_SEQ_REGEX.match(log)
  end
end
