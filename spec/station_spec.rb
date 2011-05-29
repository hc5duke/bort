require 'spec_helper'

describe Station do
  describe "when querying station access" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stnaccess'))
      @access = Station::Access.new('dubl')
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
      @info = Station::Info.new('24TH')
    end

    it "should parse download data" do
      @info.origin.should == '24TH'
      @info.name.should == '24th St. Mission'
      @info.abbreviation.should == '24TH'
      @info.geo.inspect.should == %q(["37.752254", "-122.418466"])
      @info.address.should == '2800 Mission Street'
      @info.city.should == 'San Francisco'
      @info.county.should == 'sanfrancisco'
      @info.state.should == 'CA'
      @info.zip.should == '94110'
      @info.north_routes.length.should == 4
      @info.south_routes.length.should == 4
      @info.north_platforms.first.should == 2
      @info.south_platforms.first.should == 1
      @info.platform_info.length.should > 10
      @info.intro.length.should > 10
      @info.cross_street.length.should > 10
      @info.food.length.should > 10
      @info.shopping.length.should > 10
      @info.attraction.length.should > 10
      @info.link.should == ''
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
