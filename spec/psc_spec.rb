require File.expand_path("../spec_helper", __FILE__)

describe Psc do
  describe '.xml' do
    it "provides an xml builder configured for PSC XML" do
      Psc.xml('period', :id => 'foo') { |xml| xml.tag!('planned-activity') }.should ==
        "<period id=\"foo\" xmlns=\"http://bioinformatics.northwestern.edu/ns/psc\">\n  <planned-activity/>\n</period>\n"
    end
  end

  describe '.xml_namespace' do
    it 'is a hash suitable for use with nokogiri xpath' do
      Psc.xml_namespace['psc'].should == 'http://bioinformatics.northwestern.edu/ns/psc'
    end
  end
end
