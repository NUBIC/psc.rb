require 'psc/faraday'

module Psc
  module Faraday
    class PscToken
      def initialize(app, token_or_creator)
        @app = app
        if token_or_creator.respond_to?(:call)
          @token_creator = token_or_creator
        else
          @token_creator = lambda { token_or_creator }
        end
      end

      def call(env)
        env[:request_headers]['Authorization'] = "psc_token #{token}"

        @app.call
      end

      def token
        @token_creator.call
      end
    end
  end
end
