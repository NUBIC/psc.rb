require File.expand_path("../../../spec_helper", __FILE__)

module Psc::Faraday
  describe PscToken do
    let(:app) { mock('app') }
    let(:env) { { :request_headers => ::Faraday::Utils::Headers.new } }

    before { app.stub!(:call) }

    describe "with a static token" do
      subject { PscToken.new(app, 'jo-9') }

      it 'adds the appropriate Authorization header' do
        subject.call(env)
        env[:request_headers]['Authorization'].should == 'psc_token jo-9'
      end

      it 'continues the chain' do
        app.should_receive(:call)
        subject.call(env)
      end
    end

    describe "with a dynamic token" do
      subject { PscToken.new(app, lambda { i ** 2 }) }

      def i
        @i ||= 7
        @i += 1
      end

      it 'adds the appropriate Authorization header' do
        subject.call(env)
        env[:request_headers]['Authorization'].should == 'psc_token 64'
      end

      it 'invokes the lambda for each call' do
        subject.call(env)
        subject.call(env)
        env[:request_headers]['Authorization'].should == 'psc_token 81'
      end

      it 'continues the chain' do
        app.should_receive(:call)
        subject.call(env)
      end
    end
  end
end
