require File.expand_path('../../../spec_helper', __FILE__)

module Psc::Faraday
  describe AcceptPscTypes do
    include_context 'middleware'
    include_context 'unconditional middleware'

    subject { AcceptPscTypes.new(app) }

    it 'sets the accept header if not set' do
      do_call

      headers['Accept'].should == 'application/json,text/xml'
    end

    it 'leaves the accept header alone if set' do
      headers['Accept'] = 'application/x-calendar'
      do_call
      headers['Accept'].should == 'application/x-calendar'
    end
  end
end
