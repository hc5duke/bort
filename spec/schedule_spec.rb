require 'spec_helper'

describe Schedule do
  describe "when querying arrival times" do

    before :each do
      eta_file = File.read(File.expand_path('../responses/schedule_arrive.xml', __FILE__))
      Util.stub!(:download).and_return(eta_file)

      @arrive       = Schedule::Arrive.new('dubl', 'daly')
      @origin_time  = Time.parse('May 27 16:50:00 -0700 2011')
      @xfer_time    = Time.parse('May 27 16:53:00 -0700 2011')
      @dest_time    = Time.parse('May 27 17:14:00 -0700 2011')
      @origin_date  = Date.new(2011, 5, 27)
      @xfer_date    = @origin_date
      @dest_date    = @origin_date

    end

    it "should parse trip data" do
      @arrive.trips.length.should == 4
      trip = @arrive.trips.first
      trip.origin.should            == 'ASHB'
      trip.destination.should       == 'CIVC'
      trip.fare.should              == 3.5
      trip.origin_time.should       == @origin_time
      trip.origin_date.should       == @origin_date
      trip.destination_time.should  == @dest_time
      trip.destination_date.should  == @dest_date
    end

    it "should parse leg data" do
      @arrive.trips.map(&:legs).length.should == 4
      leg = @arrive.trips.first.legs.first
      leg.order.should              == 1
      leg.transfer_code.should      == 'S'
      leg.origin.should             == 'ASHB'
      leg.destination.should        == 'MCAR'
      leg.origin_time.should        == @origin_time
      leg.origin_date.should        == @origin_date
      leg.destination_time.should   == @xfer_time
      leg.destination_date.should   == @xfer_date
      leg.line.should               == 'ROUTE 4'
      leg.bikeflag.should           == true
      leg.train_head_station.should == 'FRMT'
    end
  end
end
