require 'spec_helper'

describe Route do
  describe "when querying routes" do

    before :each do
      Util.stub!(:download).and_return(response_file('route', 'routes'))

      @routes = Route::Routes.new
    end

    it "should parse download data" do
      @routes.routes.length.should == 10
      all_routes = ["DALY-DUBL", "DALY-FRMT", "DUBL-DALY", "FRMT-DALY", "FRMT-RICH", "MLBR-RICH", "PITT-SFIA", "RICH-FRMT", "RICH-MLBR", "SFIA-PITT"]
      @routes.routes.map(&:abbreviation).sort.inspect.should == all_routes.inspect
    end

    it "should get info on particular routes" do
      Util.stub!(:download).and_return(response_file('route', 'routeinfo'))
      info = @routes.routes.first.info
      info.stations.count.should == 19
    end
  end

  describe "when querying routeinfo" do
    before :each do
      Util.stub!(:download).and_return(response_file('route', 'routeinfo'))

      @routeInfo = Route::RouteInfo.new(1)
    end

    it "should parse download data" do
      @routeInfo.stations.count.should == 19
    end
  end
end
