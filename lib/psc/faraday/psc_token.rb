require 'psc/faraday'

module Psc
  module Faraday
    ##
    # Faraday middleware that implements the `psc_token`
    # authentication type. Tokens may either be static or computed
    # per request.
    class PscToken
      ##
      # Create a new instance of the middleware.
      #
      # @param [#call] app
      # @param [#call,String] token_or_creator if the value for this
      #   parameter responds to `call`, it will be called to create a
      #   token on each request. Otherwise it will be used as a static
      #   token value.
      def initialize(app, token_or_creator)
        @app = app
        if token_or_creator.respond_to?(:call)
          @token_creator = token_or_creator
        else
          @token_creator = lambda { token_or_creator }
        end
      end

      ##
      # Adds the `Authorization` header using the configured token creator.
      def call(env)
        env[:request_headers]['Authorization'] = "psc_token #{token}"

        @app.call
      end

      private

      def token
        @token_creator.call
      end
    end
  end
end
