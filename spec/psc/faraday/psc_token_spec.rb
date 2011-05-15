require File.expand_path("../../../spec_helper", __FILE__)

module Psc::Faraday
  describe PscToken do
    include_context "middleware"

    describe "with a static token" do
      it_behaves_like "unconditional middleware"

      subject { PscToken.new(app, 'jo-9') }

      it 'adds the appropriate Authorization header' do
        do_call
        headers['Authorization'].should == 'psc_token jo-9'
      end
    end

    describe "with a dynamic token" do
      it_behaves_like "unconditional middleware"

      subject do
        i = 7
        PscToken.new(app, lambda { i += 1; i ** 2 })
      end

      it 'adds the appropriate Authorization header' do
        do_call
        headers['Authorization'].should == 'psc_token 64'
      end

      it 'invokes the lambda for each call' do
        do_call
        do_call
        headers['Authorization'].should == 'psc_token 81'
      end
    end
  end
end
