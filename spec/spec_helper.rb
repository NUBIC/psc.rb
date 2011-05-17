require 'bundler'
Bundler.setup

require 'rspec'
require 'webmock/rspec'
require File.expand_path("../middleware_helper.rb", __FILE__)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'psc'

RSpec.configure do
  def http_fixture(name)
    File.new(File.expand_path("../fixtures/#{name}.http", __FILE__))
  end
end
