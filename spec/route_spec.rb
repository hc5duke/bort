require 'spec_helper'

describe Route do
  describe "when querying routes" do

    before :each do
      eta_file = File.read(File.expand_path('../responses/route_routes.xml', __FILE__))
      Util.stub!(:download).and_return(eta_file)

      @routes = Route::Routes.new
    end

    it "should parse download data" do
      @routes.routes.length.should == 10
      all_routes = ["DALY-DUBL", "DALY-FRMT", "DUBL-DALY", "FRMT-DALY", "FRMT-RICH", "MLBR-RICH", "PITT-SFIA", "RICH-FRMT", "RICH-MLBR", "SFIA-PITT"]
      @routes.routes.map(&:abbreviation).sort.inspect.should == all_routes.inspect
    end
  end

  describe "when querying routeinfo" do
    before :each do
      eta_file = File.read(File.expand_path('../responses/route_routeinfo.xml', __FILE__))
      Util.stub!(:download).and_return(eta_file)

      @routeInfo = Route::RouteInfo.new(1)
    end

    it "should parse download data" do
      @routeInfo.stations.count.should == 19
    end
  end
end
