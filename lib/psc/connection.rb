require 'psc'
require 'faraday'
require 'faraday_stack'

module Psc
  class Connection < ::Faraday::Connection
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
