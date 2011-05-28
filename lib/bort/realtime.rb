module Bort
  module Realtime
    class Etd
      attr_accessor :origin, :platform, :direction, :etds

      def initialize(options)
        origin    = options.delete(:origin)
        platform  = options.delete(:platform)
        direction = options.delete(:direction)

        raise InvalidOrigin.new(origin) unless origin && Util.stations.keys.include?(origin.downcase.to_sym)

        download_options = {
          :action => 'etd',
          :cmd => 'etd',
        }
        download_options[:orig] = origin
        download_options[:plat] = '' if platform
        download_options[:dir]  = '' if direction

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.etds = (data/:etd).map do |etd|
          trains = (etd/:estimate).map do |estimate|
            {
              :minutes    => (estimate/:minutes).inner_html.to_i,
              :platform   => (estimate/:platform).inner_html,
              :direction  => (estimate/:direction).inner_html,
              :length     => (estimate/:length).inner_html,
              :color      => (estimate/:color).inner_html,
              :hexcolor   => (estimate/:hexcolor).inner_html,
              :bikeflag   => (estimate/:bikeflag).inner_html,
            }
          end

          {
            :destination  => (etd/:destination).inner_html,
            :abbreviation => (etd/:abbreviation).inner_html,
            :estimates    => trains,
          }
        end
      end
    end

    class InvalidOrigin < RuntimeError; end
  end
end
