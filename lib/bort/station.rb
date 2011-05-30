module Bort
  module Station
    def self.access_info(station, print_legend=false)

      download_options = {
        :action => 'station',
        :cmd => 'stnaccess',
        :orig => station,
        :l => print_legend ? '1' : '0',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      puts (data/:legend).inner_text if print_legend
      Station.new((data/:station).first)
    end

    def self.info(station)
      download_options = {
        :action => 'station',
        :cmd => 'stninfo',
        :orig => station,
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      Station.new(data)
    end

    def self.stations

      download_options = {
        :action => 'station',
        :cmd => 'stns',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      (data/:station).map{|station| Station.new(station)}
    end

    class Station
      attr_accessor :abbreviation, :destinations,
        :north_platforms, :north_routes, :south_platforms, :south_routes, :platform_info,
        :geo, :address, :city, :county, :state, :zip, :cross_street,
        :bike_flag, :bike_station_flag, :bike_station_text,
        :parking, :parking_flag, :transit_info, :car_share, :entering, :exiting,
        :attraction, :shopping, :food, :intro, :locker_flag, :lockers, :fill_time, :link

      def initialize(doc)
        self.abbreviation       = (doc/:abbr).inner_text
        self.destinations       = (doc/:destinations).inner_text

        self.north_routes       = (doc/:north_routes/:route).map(&:inner_text)
        self.south_routes       = (doc/:south_routes/:route).map(&:inner_text)
        self.north_platforms    = (doc/:north_platforms/:platform).map(&:inner_text).map(&:to_i)
        self.south_platforms    = (doc/:south_platforms/:platform).map(&:inner_text).map(&:to_i)
        self.platform_info      = (doc/:platform_info).inner_text

        latitude                = (doc/:gtfs_latitude).inner_text
        longitude               = (doc/:gtfs_longitude).inner_text
        self.geo                = [latitude, longitude] if latitude and longitude
        self.address            = (doc/:address).inner_text
        self.city               = (doc/:city).inner_text
        self.county             = (doc/:county).inner_text
        self.state              = (doc/:state).inner_text
        self.zip                = (doc/:zipcode).inner_text
        self.cross_street       = (doc/:cross_street).inner_text

        self.bike_flag          = parse_flag(doc.attributes['bike_flag']) rescue ''
        self.bike_station_flag  = parse_flag(doc.attributes['bike_station_flag']) rescue ''
        self.bike_station_text  = (doc/:bike_station_text).inner_text
        self.parking            = (doc/:parking).inner_text
        self.parking_flag       = parse_flag(doc.attributes['parking_flag']) rescue ''
        self.transit_info       = (doc/:transit_info).inner_text
        self.car_share          = (doc/:car_share).inner_text
        self.entering           = (doc/:entering).inner_text
        self.exiting            = (doc/:exiting).inner_text

        self.attraction         = (doc/:attraction).inner_text
        self.shopping           = (doc/:shopping).inner_text
        self.food               = (doc/:food).inner_text
        self.intro              = (doc/:intro).inner_text
        self.locker_flag        = parse_flag(doc.attributes['locker_flag']) rescue ''
        self.lockers            = (doc/:lockers).inner_text
        self.fill_time          = (doc/:fill_time).inner_text
        self.link               = (doc/:link).inner_text
      end

      def parse_flag(flag)
        case flag
        when '1' then true
        when '0' then false
        else nil
        end
      end
    end
  end
end
