module Bort
  module Station
    class Access
      attr_accessor :origin, :legend, :parking_flag, :bike_flag,
        :bike_station_flag, :locker_flag, :abbreviation,
        :entering, :exiting, :parking, :fill_time, :car_share,
        :lockers, :bike_station_text, :destinations, :transit_info, :link

      def initialize(orig, options={})
        self.origin = orig
        load_options(options)

        download_options = {
          :action => 'station',
          :cmd => 'stnaccess',
          :orig => origin,
          :l => legend,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.legend             = (data/:legend).inner_text
        station_data            = (data/:station).first
        self.parking_flag       = station_data.attributes['parking_flag'] == '1'
        self.bike_flag          = station_data.attributes['bike_flag'] == '1'
        self.bike_station_flag  = station_data.attributes['bike_station_flag'] == '1'
        self.locker_flag        = station_data.attributes['locker_flag'] == '1'
        self.abbreviation       = (station_data/:abbr).inner_text
        self.entering           = (station_data/:entering).inner_text
        self.exiting            = (station_data/:exiting).inner_text
        self.parking            = (station_data/:parking).inner_text
        self.fill_time          = (station_data/:fill_time).inner_text
        self.car_share          = (station_data/:car_share).inner_text
        self.lockers            = (station_data/:lockers).inner_text
        self.bike_station_text  = (station_data/:bike_station_text).inner_text
        self.destinations       = (station_data/:destinations).inner_text
        self.transit_info       = (station_data/:transit_info).inner_text
        self.link               = (station_data/:link).inner_text
      end

      private
      def load_options(options)
        self.legend = options.delete(:legend)
      end
    end

    class Info
      attr_accessor :origin, :abbreviation, :geo, :address, :city,
        :county, :state, :zip, :north_routes, :south_routes,
        :north_platforms, :south_platforms, :platform_info,
        :intro, :cross_street, :food, :shopping, :attraction, :link

      def initialize(orig)
        self.origin = orig

        download_options = {
          :action => 'station',
          :cmd => 'stninfo',
          :orig => origin,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.abbreviation     = (data/:abbr).inner_text
        self.geo              = [(data/:gtfs_latitude).inner_text, (data/:gtfs_longitude).inner_text]
        self.address          = (data/:address).inner_text
        self.city             = (data/:city).inner_text
        self.county           = (data/:county).inner_text
        self.state            = (data/:state).inner_text
        self.zip              = (data/:zipcode).inner_text
        self.north_routes     = (data/:north_routes/:route).map(&:inner_text)
        self.south_routes     = (data/:south_routes/:route).map(&:inner_text)
        self.north_platforms  = (data/:north_platforms/:platform).map(&:inner_text).map(&:to_i)
        self.south_platforms  = (data/:south_platforms/:platform).map(&:inner_text).map(&:to_i)
        self.platform_info    = (data/:platform_info).inner_text
        self.intro            = (data/:intro).inner_text
        self.cross_street     = (data/:cross_street).inner_text
        self.food             = (data/:food).inner_text
        self.shopping         = (data/:shopping).inner_text
        self.attraction       = (data/:attraction).inner_text
        self.link             = (data/:link).inner_text
      end
    end

    def self.stations

      download_options = {
        :action => 'station',
        :cmd => 'stns',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      (data/:station).map{|station| StationData.new(station)}
    end

    # TODO probably could reuse this class in Station::Info
    class StationData
      attr_accessor :abbreviation, :address, :city, :county, :state, :zip

      def initialize(doc)
        self.abbreviation = (doc/:abbr).inner_text
        self.address      = (doc/:address).inner_text
        self.city         = (doc/:city).inner_text
        self.county       = (doc/:county).inner_text
        self.state        = (doc/:state).inner_text
        self.zip          = (doc/:zipcode).inner_text
      end
    end
  end
end
