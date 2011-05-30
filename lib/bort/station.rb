module Bort
  module Station
    class Station
      attr_accessor :abbreviation, :destinations,
        :north_platforms, :north_routes, :south_platforms, :south_routes, :platform_info,
        :geo, :address, :city, :county, :state, :zip, :cross_street,
        :bike_flag, :bike_station_flag, :bike_station_text,
        :parking, :parking_flag, :transit_info, :car_share, :entering, :exiting,
        :attraction, :shopping, :food, :intro, :locker_flag, :lockers, :fill_time, :link

      def self.parse(doc)
        station = Station.new
        station.abbreviation      = (doc/:abbr).inner_text
        station.destinations      = (doc/:destinations).inner_text

        station.north_routes      = (doc/:north_routes/:route).map(&:inner_text)
        station.south_routes      = (doc/:south_routes/:route).map(&:inner_text)
        station.north_platforms   = (doc/:north_platforms/:platform).map(&:inner_text).map(&:to_i)
        station.south_platforms   = (doc/:south_platforms/:platform).map(&:inner_text).map(&:to_i)
        station.platform_info     = (doc/:platform_info).inner_text

        latitude                  = (doc/:gtfs_latitude).inner_text
        longitude                 = (doc/:gtfs_longitude).inner_text
        station.geo               = [latitude, longitude] if latitude and longitude
        station.address           = (doc/:address).inner_text
        station.city              = (doc/:city).inner_text
        station.county            = (doc/:county).inner_text
        station.state             = (doc/:state).inner_text
        station.zip               = (doc/:zipcode).inner_text
        station.cross_street      = (doc/:cross_street).inner_text

        station.bike_flag         = parse_flag(doc.attributes['bike_flag'])
        station.bike_station_flag = parse_flag(doc.attributes['bike_station_flag'])
        station.bike_station_text = (doc/:bike_station_text).inner_text
        station.parking           = (doc/:parking).inner_text
        station.parking_flag      = parse_flag(doc.attributes['parking_flag'])
        station.transit_info      = (doc/:transit_info).inner_text
        station.car_share         = (doc/:car_share).inner_text
        station.entering          = (doc/:entering).inner_text
        station.exiting           = (doc/:exiting).inner_text

        station.attraction        = (doc/:attraction).inner_text
        station.shopping          = (doc/:shopping).inner_text
        station.food              = (doc/:food).inner_text
        station.intro             = (doc/:intro).inner_text
        station.locker_flag       = parse_flag(doc.attributes['locker_flag'])
        station.lockers           = (doc/:lockers).inner_text
        station.fill_time         = (doc/:fill_time).inner_text
        station.link              = (doc/:link).inner_text

        station
      end

      def self.parse_flag(flag)
        case flag
        when '1' then true
        when '0' then false
        else nil
        end
      end
    end

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
      Station.parse((data/:station).first)
    end

    def self.info(station)
      download_options = {
        :action => 'station',
        :cmd => 'stninfo',
        :orig => station,
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      Station.parse((data/:station).first)
    end

    def self.stations

      download_options = {
        :action => 'station',
        :cmd => 'stns',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      (data/:station).map{|station| Station.parse(station)}
    end

  end
end
