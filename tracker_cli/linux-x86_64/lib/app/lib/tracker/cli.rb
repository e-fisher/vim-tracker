require 'optparse'

module Tracker
  class Cli
    attr_reader :params

    def initialize(argv)
      @params = parse_options(argv)
    end

    def run
      Heartbeat.new(params).send
    end

    def parse_options(argv)
      argv << '-h' if argv.empty?
      options = {}

      optparse = OptionParser.new do |opts|
        opts.banner = "Tracker command line interface.\n\n"

        opts.on("-a", "--api-key APIKEY", "Api key") do |api_key|
          options[:api_key] = api_key
        end

        opts.on("-e", "--file PATH", "Absolute path to file for the heartbeat") do |path|
          options[:file] = path
        end

        opts.on("-p", "--plugin PLUGIN", "Plugin info") do |plugin|
          options[:plugin] = plugin
        end

        opts.on("-w", "--write", "Is write") do |write|
          options[:write] = true
        end

        opts.on_tail("-h", "--help", "Displays help") do
          puts opts
          exit
        end

      end
      optparse.parse!

      mandatory = [:file]
      missing = mandatory.select{ |param| options[param].nil? }
      unless missing.empty?
        raise OptionParser::MissingArgument.new(missing.join(', '))
      end
      options

    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $!.to_s
      puts optparse
      exit
    end
  end
end
