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

  s.add_dependency 'faraday', '~> 0.6.1'
  s.add_dependency 'builder', '> 2.2'

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'ci_reporter', '~> 1.6'
  s.add_development_dependency 'cucumber', '~> 0.10.2'
  s.add_development_dependency 'childprocess', '~> 0.1'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'highline'
end
