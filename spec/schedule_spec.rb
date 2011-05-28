require 'spec_helper'

describe Schedule do
  describe "when querying arrival times" do

    before :each do
      eta_file = File.read(File.expand_path('../responses/schedule_arrive.xml', __FILE__))
      Util.stub!(:download).and_return(eta_file)

      @arrive = Schedule::Arrive.new('dubl', 'daly')
    end

    it "should parse download data" do
      puts @arrive.trips.length.should == 4
    end
  end
end
