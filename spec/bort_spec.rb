require 'spec_helper'

describe Bort do
  describe "when using shortcuts" do
    it "should get real time estimates" do
      Util.stub!(:download).and_return(response_file('realtime', 'etd'))
      estimates = Bort.estimates('rich')
      estimates.trains.length.should == 5
    end

    it "should get trips per arrival time" do
      Util.stub!(:download).and_return(response_file('schedule', 'arrive'))
      schedule = Bort.trips('dubl', 'rich', :by => 'arrival')
      schedule.length.should == 4
    end

    it "should get estimates" do
      Util.stub!(:download).and_return(response_file('realtime', 'etd'))
      Bort.estimates('rich')
    end

    it "should get routes" do
      Util.stub!(:download).and_return(response_file('route', 'routes'))
      Bort.routes
    end

    it "should get route info" do
      Util.stub!(:download).and_return(response_file('route', 'routeinfo'))
      Bort.route_info(1)
    end

    it "should get trip data" do
      Util.stub!(:download).and_return(response_file('schedule', 'arrive'))
      Bort.trips('dubl', 'rich')
    end

    it "should get fare" do
      Util.stub!(:download).and_return(response_file('schedule', 'fare'))
      Bort.fare('dubl', 'rich')
    end

    it "should get schedules" do
      Util.stub!(:download).and_return(response_file('schedule', 'scheds'))
      Bort.schedules
    end

    it "should get station schedule" do
      Util.stub!(:download).and_return(response_file('schedule', 'stnsched'))
      Bort.schedule_at('dubl')
    end

    it "should get stations" do
      Util.stub!(:download).and_return(response_file('station', 'stns'))
      Bort.stations
    end

    it "should get station info" do
      Util.stub!(:download).and_return(response_file('station', 'stninfo'))
      Bort.station_info('dubl')
    end
  end
end
