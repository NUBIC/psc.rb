require 'psc/faraday'

require 'base64'

module Psc::Faraday
  ##
  # Faraday middleware that implements [HTTP Basic][]. This is not
  # PSC-specific, and Faraday even includes HTTP Basic support, but
  # Faraday's support is not implemented as middleware. Using
  # middleware makes setting up a connection based on the
  # `:authenticator` option cleaner.
  #
  # [HTTP Basic]: http://www.ietf.org/rfc/rfc2617.txt
  class HttpBasic
    ##
    # Create an instance of the middleware.
    #
    # @param [#call] app
    # @param [String] username
    # @param [String] password
    def initialize(app, username, password)
      @app = app
      @header_value = "Basic #{Base64.encode64([username, password].join(':')).strip}"
    end

    ##
    # Sets the `Authorization` request header using the HTTP Basic
    # scheme.
    def call(env)
      env[:request_headers]['Authorization'] = @header_value

      @app.call(env)
    end
  end
end
