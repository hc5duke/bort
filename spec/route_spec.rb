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

    it "should get info and schedule on particular routes" do
      Util.stub!(:download).and_return(response_file('route', 'routeinfo'))
      info = @routes.routes.first.info
      info.stations.count.should == 19

      Util.stub!(:download).and_return(response_file('schedule', 'routesched'))
      schedule = @routes.routes.first.schedule
      schedule.schedule_number.should  == 29
      schedule.date.to_s.should        == '2011-05-27'
      schedule.trains.length.should    == 52
    end
  end

  describe "when querying routeinfo" do
    before :each do
      Util.stub!(:download).and_return(response_file('route', 'routeinfo'))

      @routeInfo = Route::Info.new(1)
    end

    it "should parse download data" do
      @routeInfo.stations.count.should == 19
    end
  end
end
