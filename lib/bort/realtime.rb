module Bort
  module Realtime
    class Estimates
      attr_accessor :origin, :platform, :direction, :fetched_at, :estimates

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

        self.fetched_at = Time.parse((data/:time).inner_html)
        self.estimates  = (data/:etd).map{|etd| EstimateData.new(etd)}
      end

      private
      def load_options(options)
        self.platform  = options.delete(:platform)
        self.direction = options.delete(:direction)

        raise InvalidOrigin.new(origin)       unless Util.stations.keys.map(&:to_s).include?(origin.downcase)
        raise InvalidPlatform.new(platform)   unless platform.nil? || VALID_PLATFORMS.include?(platform.to_s)
        raise InvalidDirection.new(direction) unless direction.nil? || VALID_DIRECTIONS.include?(direction.to_s)
      end
    end

    class EstimateData
      attr_accessor :destination, :abbreviation, :estimates
      def initialize(doc)
        self.destination  = (doc/:destination).inner_html
        self.abbreviation = (doc/:abbreviation).inner_html
        self.estimates    = (doc/:estimate).map{|estimate| Train.new(estimate)}
      end
    end

    class Train
      attr_accessor :minutes, :platform, :direction, :length, :color, :hexcolor, :bikeflag

      def initialize(estimate)
        self.minutes    = (estimate/:minutes).inner_html.to_i
        self.platform   = (estimate/:platform).inner_html
        self.direction  = (estimate/:direction).inner_html
        self.length     = (estimate/:length).inner_html
        self.color      = (estimate/:color).inner_html
        self.hexcolor   = (estimate/:hexcolor).inner_html
        self.bikeflag   = (estimate/:bikeflag).inner_html
      end
    end

    class InvalidOrigin     < RuntimeError; end
    class InvalidPlatform   < RuntimeError; end
    class InvalidDirection  < RuntimeError; end

  end
end
