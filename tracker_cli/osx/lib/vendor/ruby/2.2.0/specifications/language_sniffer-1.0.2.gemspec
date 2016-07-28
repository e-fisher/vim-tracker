# -*- encoding: utf-8 -*-
# stub: language_sniffer 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "language_sniffer"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["GitHub, Inc.", "Michael Grosser"]
  s.date = "2012-05-05"
  s.email = "grosser.michael@gmail.com"
  s.executables = ["language_sniffer"]
  s.files = ["bin/language_sniffer"]
  s.homepage = "http://github.com/grosser/language_sniffer"
  s.rubygems_version = "2.4.8"
  s.summary = "Language detection"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
