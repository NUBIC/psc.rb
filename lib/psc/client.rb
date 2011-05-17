require 'psc'

module Psc
  ##
  # A high-level interface to a PSC instance's API. This class does
  # not expose everything you can do with the API &mdash; only a few
  # of the more common elements. Refer to the API documentation and
  # use {Psc::Connection} for complete access.
  class Client
    ##
    # The connection that the client is using to access PSC. Use it to
    # make requests that the high-level interface doesn't support.
    #
    # @return [Psc::Connection]
    attr_reader :connection

    ##
    # Create a new client instance. The given url and options will be
    # used to create a {Psc::Connection} for the client to use; see
    # that class for more details about what is permitted
    def initialize(url, options, &block)
      @connection = Psc::Connection.new(url, options, &block)
    end

    ##
    # Returns an array of hashes describing the studies in the system.
    # The contents are from the JSON representation of the `/studies`
    # resource.
    #
    # @return [Array<Hash>]
    def studies
      connection.get('studies.json').body['studies']
    end
  end
end
