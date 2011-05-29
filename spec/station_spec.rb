require 'spec_helper'

describe Station do
  describe "when querying station access" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stnaccess'))
      @access = Bort::Station::Access.new('dubl')
    end

    it "should parse download data" do
      @access.origin.should == 'dubl'
      @access.legend.length.should > 10
      @access.parking_flag.should == false
      @access.bike_flag.should == false
      @access.bike_station_flag.should == false
      @access.locker_flag.should == true
      @access.name.should == '12th St. Oakland City Center'
      @access.abbreviation.should == '12TH'
      @access.entering.length.should > 10
      @access.exiting.length.should > 10
      @access.parking.length.should > 10
      @access.fill_time.should == ''
      @access.car_share.should == ''
      @access.lockers.length.should > 10
      @access.bike_station_text.should == ''
      @access.destinations.length.should > 10
      @access.transit_info.length.should > 10
      @access.link.should == ''
    end
  end

  describe "when querying station info" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stninfo'))
    end

    it "should parse download data" do
    end
  end

  describe "when querying stations" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stns'))
    end

    it "should parse download data" do
    end
  end
end
