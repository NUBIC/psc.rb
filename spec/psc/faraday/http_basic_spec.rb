require File.expand_path("../../../spec_helper", __FILE__)

module Psc::Faraday
  describe HttpBasic do
    subject { HttpBasic.new(app, 'jo', 'basil') }

    let(:app) { mock('app') }
    let(:env) { { :request_headers => ::Faraday::Utils::Headers.new } }

    before { app.stub!(:call) }

    it 'adds the appropriate Authorization header' do
      subject.call(env)
      env[:request_headers]['Authorization'].should == 'Basic am86YmFzaWw='
    end

    it 'continues the chain' do
      app.should_receive(:call)
      subject.call(env)
    end
  end
end
