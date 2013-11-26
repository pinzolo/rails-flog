# coding: utf-8
require "active_support"
require "active_record"
require "action_controller"
require "flog"
require "test/unit"

class TestLogger
  attr_accessor :debugs, :infos
  def initialize
    @debugs = []
    @infos = []
  end

  def debug?
    true
  end

  def debug(message)
    @debugs += message.split("\n")
  end

  def info(message)
    @infos << message
  end
end
