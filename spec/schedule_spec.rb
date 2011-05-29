require 'spec_helper'

describe Schedule do
  describe "when querying arrival times" do

    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'arrive'))

      @arrive       = Schedule::Arrive.new('dubl', 'daly')
      @arrive_time  = Time.parse('May 27 17:28:00 -0700 2011')
      @origin_time  = Time.parse('May 27 16:50:00 -0700 2011')
      @xfer_time    = Time.parse('May 27 16:53:00 -0700 2011')
      @dest_time    = Time.parse('May 27 17:14:00 -0700 2011')
      @all_date     = Date.new(2011, 5, 27)

    end

    it "should parse download data" do
      @arrive.origin.should == 'dubl'
      @arrive.destination.should == 'daly'
      @arrive.time.should == @arrive_time
      @arrive.date.should == @all_date
      @arrive.before.should == 2
      @arrive.after.should == 2
      @arrive.legend.length.should > 10 # some text
    end

    it "should parse trip data" do
      @arrive.trips.length.should == 4
      trip = @arrive.trips.first
      trip.origin.should            == 'ASHB'
      trip.destination.should       == 'CIVC'
      trip.fare.should              == 3.5
      trip.origin_time.should       == @origin_time
      trip.origin_date.should       == @all_date
      trip.destination_time.should  == @dest_time
      trip.destination_date.should  == @all_date
    end

    it "should parse leg data" do
      @arrive.trips.map(&:legs).length.should == 4
      leg = @arrive.trips.first.legs.first
      leg.order.should              == 1
      leg.transfer_code.should      == 'S'
      leg.origin.should             == 'ASHB'
      leg.destination.should        == 'MCAR'
      leg.origin_time.should        == @origin_time
      leg.origin_date.should        == @all_date
      leg.destination_time.should   == @xfer_time
      leg.destination_date.should   == @all_date
      leg.line.should               == 'ROUTE 4'
      leg.bikeflag.should           == true
      leg.train_head_station.should == 'FRMT'
    end
  end

  describe "when querying fares" do

    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'fare'))
      @fare = Schedule::Fare.new('dubl', 'daly')
    end

    it "should parse download data" do
      @fare.schedule_number.should  == 29
      @fare.fare.should             == 3.1
    end
  end

  describe "when querying holidays" do

    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'holiday'))
      @holiday = Schedule::Holiday.new
    end

    it "should parse download data" do
      @holiday.holidays.length.should == 9
      holiday = @holiday.holidays.first
      holiday.name.should == 'Thanksgiving Day'
      holiday.date.to_s.should == '2010-11-25'
      holiday.schedule_type.should == 'Sunday'
    end
  end

  describe "when querying route schedule" do

    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'routesched'))
      @schedule = Schedule::RouteSchedule.new(6)
    end

    it "should parse download data" do
      @schedule.schedule_number.should  == 29
      @schedule.date.to_s.should        == '2011-05-27'
      @schedule.trains.length.should    == 52

      train = @schedule.trains.first
      train.index.should == 1
      train.stops.length.should == 19

      stop = train.stops.first
      stop.station.should == 'DALY'
      stop.origin_time.should == Time.parse('May 27 06:13:00 -0700 2011')
      stop.bikeflag.should == true
    end
  end

  describe "when querying schedules" do
    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'scheds'))
      @schedules = Schedule::Schedules.new
    end

    it "should parse download data" do
      @schedules.schedules.length.should == 4
      schedule = @schedules.schedules.first
      schedule.schedule_id.should == 29
      schedule.effective_date.should == Time.parse('Feb 19 00:00:00 -0800 2011')
    end
  end

  describe "when querying special schedules" do
    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'special'))
    end

    it "should parse download data" do
    end
  end

  describe "when querying station schedule" do
    before :each do
      Util.stub!(:download).and_return(response_file('schedule', 'stnsched'))
    end

    it "should parse download data" do
    end
  end

end
