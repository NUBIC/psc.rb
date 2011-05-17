require 'psc'
require 'faraday'
require 'faraday_stack'

module Psc
  ##
  # A `Faraday::Connection` set up for use with Patient Study
  # Calendar. See the {file:README.md} for a couple of examples.
  #
  # @see https://github.com/technoweenie/faraday
  # @see https://github.com/mislav/faraday-stack
  class Connection < ::Faraday::Connection
    ##
    # Create a new PSC connection. This is a `Faraday::Connection`
    # with the following middleware:
    #
    #  * Either {Psc::Faraday::HttpBasic} or {Psc::Faraday::PscToken}
    #    depending on the contents of the `:authenticator` option
    #  * {Psc::Faraday::StringIsXml}
    #  * `::Faraday::Request::JSON`
    #  * `::Faraday::Request::UrlEncoded`
    #  * `::FaradayStack::ResponseXML` for content-type text/xml
    #  * `::FaradayStack::ResponseJSON` for content-type application/json
    #  * `::Faraday::Adapter::NetHttp`
    #
    # If a block is provided, it will receive the Faraday builder so
    # that you can append more middleware. If you provide your own
    # adapter, the `net/http` adapter will not be appended.
    #
    # @param [String] url the base URL for your PSC instance
    # @param [Hash] options the options for the connection. These are
    #   same as accepted by `Faraday::Connection`, plus:
    # @option options [Hash] :authenticator parameters for the
    #   authentication middleware. These are detailed in the {file:README.md}.
    # @yield [builder] (optional)
    def initialize(url, options)
      super do |builder|
        builder.use *authentication_middleware(options[:authenticator])
        builder.use Psc::Faraday::StringIsXml
        builder.request :json
        builder.request :url_encoded
        builder.use FaradayStack::ResponseXML, :content_type => 'text/xml'
        builder.use FaradayStack::ResponseJSON, :content_type => 'application/json'

        if block_given?
          yield builder
        end

        builder.adapter :net_http unless has_adapter?(builder)
      end

      unless self.path_prefix =~ %r{/api/v1$}
        self.path_prefix = if self.path_prefix == '/'
                             '/api/v1'
                           else
                             self.path_prefix + '/api/v1'
                           end
      end
    end

    private

    def authentication_middleware(authenticator)
      unless authenticator
        raise 'No authentication method specified. Please include the :authenticator option.'
      end

      kind = authenticator.keys.first

      case kind
      when :basic
        [Psc::Faraday::HttpBasic, *authenticator[kind]]
      when :token
        [Psc::Faraday::PscToken, authenticator[kind]]
      else
        raise "Unsupported authentication method #{kind.inspect}."
      end
    end

    def has_adapter?(builder)
      builder.handlers.detect { |h| has_superclass?(h.klass, ::Faraday::Adapter) }
    end

    # It seems like there must be a builtin for this, but I'm not
    # finding it.
    def has_superclass?(child, ancestor)
      if child.superclass == ancestor
        true
      elsif child.superclass.nil?
        false
      else
        has_superclass?(child.superclass, ancestor)
      end
    end
  end
end
