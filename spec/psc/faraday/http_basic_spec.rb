require File.expand_path("../../../spec_helper", __FILE__)

module Psc::Faraday
  describe HttpBasic do
    include_context "middleware"
    it_behaves_like "unconditional middleware"

    subject { HttpBasic.new(app, 'jo', 'basil') }

    it 'adds the appropriate Authorization header' do
      do_call
      headers['Authorization'].should == 'Basic am86YmFzaWw='
    end
  end
end
