require File.expand_path('../../../spec_helper', __FILE__)

module Psc::Faraday
  describe StringIsXml do
    include_context 'middleware'
    it_behaves_like "unconditional middleware"

    subject { StringIsXml.new(app) }

    before do
      env[:body] = '<foo/>'
    end

    it 'treats a string body as text/xml' do
      do_call
      headers['Content-Type'].should == 'text/xml'
    end

    it 'leaves a Hash body alone' do
      env[:body] = { 'foo' => 'bar' }
      do_call
      headers['Content-Type'].should be_nil
    end

    it 'does nothing if the content type is already set' do
      headers['Content-Type'] = 'application/vnd.sun.wadl+xml'
      do_call
      headers['Content-Type'].should == 'application/vnd.sun.wadl+xml'
    end

    context 'in the same stack as Faraday::Request::JSON' do
      let(:conn) do
        ::Faraday::Connection.new('http://example.org/') do |builder|
          builder.use StringIsXml
          builder.use ::Faraday::Request::JSON
        end
      end

      it 'sets the content type for a string body' do
        response = conn.put('dc', '<foo/>')
        response.env[:request_headers]['Content-Type'].should == 'text/xml'
      end

      it 'does not interfere with the JSON middleware for a Hash body' do
        response = conn.put('dc', { 'bar' => 'baz' })
        response.env[:request_headers]['Content-Type'].should == 'application/json'
      end
    end
  end
end
