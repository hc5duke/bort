module Bort
  module Realtime
    class Etd
      attr_accessor :origin, :platform, :direction, :fetched_at, :etds

      VALID_PLATFORMS = %w(1 2 3 4)
      VALID_DIRECTIONS = %w(n s)
      def initialize(orig, options={})
        self.origin = orig
        load_options(options)

        download_options = {
          :action => 'etd',
          :cmd    => 'etd',
          :orig   => origin,
        }
        download_options[:plat] = platform
        download_options[:dir]  = direction

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.fetched_at = Time.parse((data/:time).inner_html)
        self.etds = (data/:etd).map{|etd| EtdData.new(etd)}
      end

      private
      def load_options(options)
        self.platform  = options.delete(:platform)
        self.direction = options.delete(:direction)

        raise InvalidOrigin.new(origin) unless Util.stations.keys.include?(origin.downcase.to_sym)
        unless platform.nil?
          raise InvalidPlatform.new(platform) unless platform.nil? || (VALID_PLATFORMS).include?(platform.to_s)
        end
        unless direction.nil?
          raise InvalidDirection.new(direction) unless (VALID_DIRECTIONS).include?(direction.to_s)
        end
      end
    end

    class EtdData
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
