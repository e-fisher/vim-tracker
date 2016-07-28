module Tracker
  module Logging
    def logger
      Logging.logger
    end

    def self.logger
      logger ||= Logger.new(Tracker.debug ? STDOUT : "#{Tracker.root}/log/tracker.log")
      logger.level = Tracker.log_level
      logger
    end
  end
end
