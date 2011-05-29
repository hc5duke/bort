require 'spec_helper'

describe Station do
  # StationInfo
  # StationAccess
  # Stations
  describe "when querying station access" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stnaccess'))
    end

    it "should parse download data" do
    end
  end

  describe "when querying station info" do

    before :each do
      Util.stub!(:download).and_return(response_file('station', 'stninfo'))
    end

    it "should parse download data" do
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
