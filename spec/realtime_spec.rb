require 'spec_helper'

describe Realtime do
  describe "when querying eta" do

    before :each do
      Util.stub!(:download).and_return(response_file('realtime', 'etd'))

      @estimates = Realtime::Estimates.new('RICH')
    end

    it "should parse download data" do
      @estimates.trains.length.should == 5
      trains = @estimates.trains
      trains.length.should == 5

      train = trains.first
      train.station.should == 'RICH'
      train.destination.should == 'FRMT'
      train.minutes.should == 6
      train.platform.should == 2
      train.direction.should == 's'
      train.length.should == 6
      train.color.should == 'orange'
      train.hexcolor.should == '#ff9933'
      train.bike_flag.should == true
    end

    it "should parse download data" do
      @estimates.trains.length.should == 5
      trains = @estimates.select(:color, 'red')
      trains.length.should == 2

      train = trains.first
      train.color.should == 'red'

      trains = @estimates.select({:color => 'red', :length => 8})
      trains.length.should == 1

      train = trains.first
      train.color.should == 'red'
      train.length.should == 8
    end
  end

end
