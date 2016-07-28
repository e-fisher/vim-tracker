require_relative "tracker/version"
require_relative "tracker/logging"
require_relative "tracker/cli"
require_relative "tracker/heartbeat"
require_relative "tracker/queue"
require_relative "tracker/constants"
require_relative "tracker/project"
require_relative "tracker/exceptions"
require 'logger'
require 'language_sniffer'
require 'parseconfig'

module Tracker
  class << self
    attr_accessor :debug

    def log_level
      debug ? Logger::DEBUG : Logger::WARN
    end

    def root
      File.dirname __dir__
    end
  end
end
