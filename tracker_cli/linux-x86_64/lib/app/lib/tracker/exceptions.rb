module Tracker
  class Error < StandardError

    def initialize(message = nil)
      @message = message
    end

    def to_s
      @message
    end
  end

  class FileMissing < Error;  end

  class ApiKeyMissing < Error
    def to_s
      'Specify api key through argument or add to ~/tracker.conf'
    end
  end
end
