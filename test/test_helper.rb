# coding: utf-8
require "coveralls"
Coveralls.wear!

require "active_support"
require "flog"
require "test/unit"

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
    @debugs += message.split("\n")
  end

  def info(message)
    @infos += message.split("\n")
  end

  def error(message)
    @errors += message.split("\n")
  end
end
