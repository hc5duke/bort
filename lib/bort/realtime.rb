module Bort
  module Realtime
    class Estimates
      attr_accessor :origin, :platform, :direction, :fetched_at, :destinations, :trains

      VALID_PLATFORMS = %w(1 2 3 4)
      VALID_DIRECTIONS = %w(n s)
      def initialize(orig, options={})
        self.origin = orig
        load_options(options)

        download_options = {
          :action => 'etd',
          :cmd    => 'etd',
          :orig   => origin,
          :plat   => platform,
          :dir    => direction,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.origin = (data/:abbr).inner_text
        self.fetched_at = Time.parse((data/:time).inner_text)
        self.trains = []
        self.destinations = []

        (data/:etd).map do |estimate|
          destination = (estimate/:abbreviation).inner_text
          self.destinations << destination
          (estimate/:estimate).map do |train|
            self.trains << Train.new(train, origin, destination)
          end
        end
      end

      private
      def load_options(options)
        self.platform  = options.delete(:platform)
        self.direction = options.delete(:direction)

        Util.validate_station(origin)
        raise InvalidPlatform.new(platform)   unless platform.nil? || VALID_PLATFORMS.include?(platform.to_s)
        raise InvalidDirection.new(direction) unless direction.nil? || VALID_DIRECTIONS.include?(direction.to_s)
      end
    end

    class Train
      attr_accessor :station, :destination, :minutes, :platform, :direction, :length, :color, :hexcolor, :bikeflag

      def initialize(doc, orig, dest)
        self.station      = orig
        self.destination  = dest
        self.minutes      = (doc/:minutes).inner_text.to_i
        self.platform     = (doc/:platform).inner_text.to_i
        self.direction    = (doc/:direction).inner_text[0,1].downcase
        self.length       = (doc/:length).inner_text.to_i
        self.color        = (doc/:color).inner_text.downcase
        self.hexcolor     = (doc/:hexcolor).inner_text.downcase
        self.bikeflag     = (doc/:bikeflag).inner_text == '1'
      end
    end

    class InvalidPlatform   < RuntimeError; end
    class InvalidDirection  < RuntimeError; end

  end
end
