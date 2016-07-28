require 'pstore'
require 'set'

module Tracker
  class Queue
    attr_reader :db

    def initialize(db)
      @db = db
      init_db if heartbeats.nil?
    end

    def store
      @store ||= PStore.new("#{Tracker.root}/db/#{db}.pstore")
    end

    def add(heartbeat)
      store.transaction { store[:heartbeats] << heartbeat }
    end

    def delete(heartbeat)
      store.transaction { store[:heartbeats].delete(heartbeat) }
    end

    def heartbeats
      store.transaction { store[:heartbeats] }
    end

    def init_db
      store.transaction { store[:heartbeats] = Set.new }
    end

    def process
      heartbeat = heartbeats.first
      delete(heartbeat) && Tracker::Heartbeat.new(heartbeat).send if heartbeat
    end
  end
end
