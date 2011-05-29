require 'spec_helper'

describe Realtime do
  describe "when querying eta" do

    before :each do
      Util.stub!(:download).and_return(response_file('realtime', 'etd'))

      @etd = Realtime::Etd.new('RICH')
    end

    it "should parse download data" do
      @etd.estimates.length.should == 2
      estimates = @etd.estimates.map(&:estimates).flatten
      estimates.length.should == 5
      estimates.map(&:minutes).sort.inspect.should == [2, 6, 14, 21, 36].inspect
    end
  end

end
