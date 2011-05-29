require 'spec_helper'

describe Realtime do
  describe "when querying eta" do

    before :each do
      Util.stub!(:download).and_return(response_file('realtime', 'etd'))

      @estimates = Realtime::Estimates.new('RICH')
    end

    it "should parse download data" do
      @estimates.estimates.length.should == 2
      trains = @estimates.trains
      trains.length.should == 5
      trains.map(&:minutes).sort.inspect.should == [2, 6, 14, 21, 36].inspect
    end
  end

end
