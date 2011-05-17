require 'psc/faraday'

module Psc
  module Faraday
    ##
    # Middleware which sets the request content type to `text/xml` if
    # the provided body is a `String` and the content type isn't
    # already set.
    class StringIsXml
      def initialize(app)
        @app = app
      end

      ##
      # Sets the content type request header if appropriate
      def call(env)
        if String === env[:body]
          env[:request_headers]['Content-Type'] ||= 'text/xml'
        end

        @app.call(env)
      end
    end
  end
end
