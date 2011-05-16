require File.expand_path("../../spec_helper.rb", __FILE__)

module Psc
  describe Connection do
    let(:conn) {
      Psc::Connection.new('http://psc.example.org/', options)
    }

    let(:options) {
      { :authenticator => { :basic => ['foo', 'bar'] } }
    }

    DEFAULT_MIDDLEWARE_COUNT = 6

    describe 'the default middleware' do
      it 'has the authentication middleware first' do
        conn.builder[0].should == Psc::Faraday::HttpBasic
      end

      it 'has the string-is-xml middleware next' do
        conn.builder[1].should == Psc::Faraday::StringIsXml
      end

      it 'has the Faraday JSON request middleware next' do
        conn.builder[2].should == ::Faraday::Request::JSON
      end

      it 'has the Faraday URL-encoded request middleware next' do
        conn.builder[3].should == ::Faraday::Request::UrlEncoded
      end

      it 'has the FaradayStack XML parser middleware next' do
        conn.builder[4].should == ::FaradayStack::ResponseXML
      end

      it 'has the FaradayStack JSON parser middleware next' do
        conn.builder[5].should == ::FaradayStack::ResponseJSON
      end
    end

    describe 'user-specified additional middleware' do
      let(:custom_conn) {
        Psc::Connection.new('http://psc.example.org/', options) do |builder|
          builder.use ::Faraday::Response::Logger
        end
      }

      it 'comes after the default middleware' do
        custom_conn.builder[DEFAULT_MIDDLEWARE_COUNT].should == ::Faraday::Response::Logger
      end

      it 'comes before the adapter' do
        custom_conn.builder.handlers.last.should == ::Faraday::Adapter::NetHttp
      end
    end

    describe 'selecting authentication middleware' do
      let(:auth_middleware) { conn.builder[0] } # this is a Faraday::Builder::Handler
      let(:auth_mw_args)    { conn.builder[0].instance_eval { @args } }

      context 'when :basic' do
        before do
          options[:authenticator] = { :basic => %w(foo bar) }
        end

        it 'uses the HttpBasic middleware' do
          auth_middleware.klass.should == Psc::Faraday::HttpBasic
        end

        it 'provides the username and password to the middleware' do
          auth_mw_args.should == %w(foo bar)
        end
      end

      context 'when :token' do
        before do
          options[:authenticator] = { :token => lambda { 'foo' } }
        end

        it 'uses the PscToken middleware' do
          auth_middleware.klass.should == Psc::Faraday::PscToken
        end

        it 'provides the token (or creator) to the middleware' do
          auth_mw_args.first.call.should == 'foo'
        end
      end

      context 'when an unknown kind' do
        before do
          options[:authenticator] = { :quuxor => 7 }
        end

        it 'raises an error' do
          lambda { conn }.should raise_error('Unsupported authentication method :quuxor.')
        end
      end

      context 'when :authenticator not specified' do
        before do
          options.delete :authenticator
        end

        it 'raises an error' do
          lambda { conn }.should raise_error(
            'No authentication method specified. Please include the :authenticator option.')
        end
      end
    end

    describe 'selecting an adapter' do
      let(:adapter) { conn.builder.handlers.last }

      it 'defaults to net/http' do
        adapter.klass.should == ::Faraday::Adapter::NetHttp
      end

      it 'uses the one the user provides if any' do
        custom_conn = Connection.new('dc', options) do |builder|
          builder.adapter :excon
        end
        custom_conn.builder.handlers.last.should == ::Faraday::Adapter::Excon
      end
    end
  end
end
