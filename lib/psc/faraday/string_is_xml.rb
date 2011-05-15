require 'psc/faraday'

module Psc
  module Faraday
    class StringIsXml
      def initialize(app)
        @app = app
      end

      def call(env)
        if String === env[:body]
          env[:request_headers]['Content-Type'] ||= 'text/xml'
        end

        @app.call(env)
      end
    end
  end
end
