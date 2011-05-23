# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "psc/version"

Gem::Specification.new do |s|
  s.name        = "psc"
  s.version     = Psc::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rhett Sutphin"]
  s.email       = ["r-sutphin@northwestern.edu"]
  s.homepage    = "https://github.com/NUBIC/psc.rb"
  s.summary     = "A lightweight ruby client for Patient Study Calendar's RESTful HTTP API"
  s.description = "A lightweight ruby client for Patient Study Calendar's RESTful HTTP API"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'faraday', '~> 0.7.0'
  s.add_dependency 'builder', '>= 2.1.2'
  s.add_dependency 'faraday-stack', '~> 0.1.1'
  s.add_dependency 'nokogiri', '~> 1.4'
  s.add_dependency 'activesupport', '>= 2.3' # for the JSON adapter

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'ci_reporter', '~> 1.6'
  s.add_development_dependency 'cucumber', '~> 0.10.2'
  s.add_development_dependency 'childprocess', '~> 0.1'
  s.add_development_dependency 'highline'
  s.add_development_dependency 'webmock', '~> 1.6'
  s.add_development_dependency 'yard', '~> 0.7.1'
end
