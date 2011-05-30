require 'spec_helper'

describe Station do
  describe "when querying station access" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stnaccess'))
      @station = Station::access_info('dubl')
    end

    it "should parse download data" do
      @station.parking_flag.should == false
      @station.bike_flag.should == false
      @station.bike_station_flag.should == false
      @station.locker_flag.should == true
      @station.abbreviation.should == '12TH'
      @station.entering.length.should > 10
      @station.exiting.length.should > 10
      @station.parking.length.should > 10
      @station.fill_time.should == ''
      @station.car_share.should == ''
      @station.lockers.length.should > 10
      @station.bike_station_text.should == ''
      @station.destinations.length.should > 10
      @station.transit_info.length.should > 10
      @station.link.should == ''
    end
  end

  describe "when querying station info" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stninfo'))
      @station = Station::info('24TH')
    end

    it "should parse download data" do
      @station.abbreviation.should == '24TH'
      @station.geo.inspect.should == %q(["37.752254", "-122.418466"])
      @station.address.should == '2800 Mission Street'
      @station.city.should == 'San Francisco'
      @station.county.should == 'sanfrancisco'
      @station.state.should == 'CA'
      @station.zip.should == '94110'
      @station.north_routes.length.should == 4
      @station.south_routes.length.should == 4
      @station.north_platforms.first.should == 2
      @station.south_platforms.first.should == 1
      @station.platform_info.length.should > 10
      @station.intro.length.should > 10
      @station.cross_street.length.should > 10
      @station.food.length.should > 10
      @station.shopping.length.should > 10
      @station.attraction.length.should > 10
      @station.link.should == ''
    end
  end

  describe "when querying stations" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stns'))
      @stations = Station.stations
    end

    it "should parse download data" do
      @stations.length.should == 44
      station = @stations.first
      station.abbreviation.should == "12TH"
      station.address.should == '1245 Broadway'
      station.city.should == 'Oakland'
      station.county.should == 'alameda'
      station.state.should == 'CA'
      station.zip.should == '94612'
    end
  end
end
