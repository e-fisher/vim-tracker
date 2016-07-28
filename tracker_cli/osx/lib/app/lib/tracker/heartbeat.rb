require "net/http"
require "uri"

module Tracker
  class Heartbeat
    include Tracker::Logging

    attr_reader :params

    def initialize(params = {})
      @params = {
        parsed_file: params.fetch(:parsed_file) { parse_file(params[:file]) },
        api_key: params.fetch(:api_key) { read_key_from_conf },
        time: params.fetch(:time, Time.now.utc.to_f),
        queue_db: params.fetch(:queue_db, 'default'),
        plugin: params.fetch(:plugin, 'unknown')
      }
      @params[:project] = params.fetch(:project, project.name)
      @params[:branch] = params.fetch(:branch, project.branch)
      @params[:language] = params.fetch(:language, language)
    end

    def send
      logger.error('Missing key') && return if params[:api_key].to_s.empty?

      uri = URI.parse(Tracker::HEARTBEAT_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)

      request.set_form_data(post_data)

      request['Authorization'] = "Bearer #{params[:api_key]}"
      request['User-Agent'] = user_agent

      logger.debug "Sending heartbeat: #{post_data}"
      response = http.request(request)
      logger.debug "Api response: #{response.code} #{response.msg}"

      return if response.code != '201'
      queue.process
      true
    rescue *Tracker::HTTP_ERRORS => e
      logger.debug "HTTP error: #{e}, queueing for retry"
      queue.add(self.to_h)
    end

    def post_data
      {
        file: params[:parsed_file],
        time: params[:time],
        project: params[:project],
        branch: params[:branch],
        language: params[:language]
      }
    end

    def queue
      @queue ||= Tracker::Queue.new(params[:queue_db])
    end

    def to_h
      params
    end

    def project
      @project ||= Project.new(params[:parsed_file])
    end

    def language
      return if params[:parsed_file].to_s.empty?
      sniffer = LanguageSniffer.detect(params[:parsed_file]).language
      sniffer.name if sniffer
    end

    def conf
      @conf ||= ParseConfig.new("#{Dir.home}/tracker.conf")
    end

    def read_key_from_conf
      return conf['api_key'] unless conf['api_key'].to_s.empty?
      raise Tracker::ApiKeyMissing
    end

    def user_agent
      os = Gem::Platform.local.os
      "Tracker v#{Tracker::VERSION} (#{os}) Plugin: #{params[:plugin]}"
    end

    def parse_file(file)
      return file if File.exists?(file.to_s)
      raise Tracker::FileMissing.new(file.to_s)
    end
  end
end
