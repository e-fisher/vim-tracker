require 'find'
module Tracker
  class Project
    attr_reader :file

    def initialize(path)
      @file = path
    end

    def name
      File.basename(project_root) if project_root
    end

    def branch
      return unless name
      head = File.open("#{project_root}/.git/HEAD", "rb").read
      head[/^ref:.*\/(.+)$/, 1]
    end

    def project_root
      traversal_find(file, '.git')
    end

    def traversal_find(path, needle)
      return unless File.exists?(path)

      path = parent_of(path) if File.file?(path)
      return path if Dir.new(path).include?('.git')

      traversal_find(parent_of(path), needle) if parent_of(path) != path
    end

    def parent_of(path)
      File.expand_path('..', path)
    end
  end
end
