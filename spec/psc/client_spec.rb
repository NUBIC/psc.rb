require File.expand_path("../../spec_helper.rb", __FILE__)

module Psc
  describe Client do
    let(:options) { { :authenticator => { :basic => %w(superuser superuser) } } }
    let(:url) { 'http://psc.example.org/' }
    let(:client) { Psc::Client.new(url, options) }

    def mockable_uri(path)
      URI.join(url.sub(%r{//}, '//superuser:superuser@'), "api/v1/#{path}").to_s
    end

    describe '.new' do
      it 'creates a connection from a string and options' do
        client.connection.should be_a(Psc::Connection)
      end

      it 'yields a connection builder if given a block' do
        client = Psc::Client.new(url, options) do |builder|
          builder.response :logger
        end
        client.connection.builder[-2].should == ::Faraday::Response::Logger
      end
    end

    describe '#studies' do
      before do
        stub_request(:get, mockable_uri('studies.json')).
          to_return(http_fixture('studies-json'))
      end

      let(:actual) { client.studies }

      it "has the data from the response" do
        actual.first['assigned_identifier'].should == 'NU 1404'
      end
    end
  end
end
