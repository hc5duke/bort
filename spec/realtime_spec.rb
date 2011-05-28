require 'spec_helper'

describe Realtime do
  before :each do
    Bort('') # fake API key
  end

  describe "when parsing ETA" do

    before :each do
      Bort('')
      eta_file = File.read(File.expand_path('../responses/realtime_etd.xml', __FILE__))
      Util.stub!(:download).and_return(eta_file)

      @etd = Realtime::Etd.new({:origin => 'RICH'})
    end

    it "should parse download data" do
      @etd.etds.length.should == 2
      estimates = @etd.etds.map{|e|e[:estimates]}.flatten
      estimates.length.should == 5
      estimates.map{|e|e[:minutes]}.sort.inspect.should == [2, 6, 14, 21, 36].inspect
    end
  end

end
