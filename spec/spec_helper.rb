require 'bundler'
Bundler.setup

require 'rspec'
require File.expand_path("../middleware_helper.rb", __FILE__)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'psc'
