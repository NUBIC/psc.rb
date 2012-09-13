require 'psc/faraday'

module Psc
  module Faraday
    ##
    # Middleware which sets the Accept header to `application/json,text/xml` if
    # it is not already set.
    class AcceptPscTypes
      DEFAULT_ACCEPT_HEADER = 'application/json,text/xml'

      def initialize(app)
        @app = app
      end

      ##
      # Sets the Accept header if appropriate
      def call(env)
        env[:request_headers]['Accept'] ||= DEFAULT_ACCEPT_HEADER

        @app.call(env)
      end
    end
  end
end
