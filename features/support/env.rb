require 'bundler'
Bundler.setup

require 'rspec'

$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'psc'

module Psc::Cucumber
  include ::RSpec::Matchers

  class World
    def int_psc
      @int_psc ||= IntPsc.new
    end

    def init_client
      @client = Psc::Client.new(
        File.join(IntPsc.url, 'api/v1'),
        :authentication => { :basic => [ 'superuser' ] * 2 }
      )
    end

    def client
      @client
    end
  end
end

World do
  Psc::Cucumber::World.new
end
