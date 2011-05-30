module Bort
  module Route
    class Routes
      attr_accessor :schedule, :date, :schedule_number, :routes

      def initialize(options={})
        load_options(options)

        download_options = {
          :action => 'route',
          :cmd => 'routes',
        }
        download_options[:sched]  = schedule
        download_options[:date]   = date

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.schedule_number = (data/:sched_num).inner_html
        self.routes = (data/:route).map do |route|
          Route.new(route)
        end
      end

      private
      def load_options(options)
        self.schedule = options.delete(:schedule)
        # date does not appear to be supported by the current API
        self.date     = options.delete(:date)

        Util.validate_date(date)
      end
    end

    class Route
      attr_accessor :name, :abbreviation, :route_id, :number, :color
      def initialize(doc)
        self.name         = (doc/:name).inner_html
        self.abbreviation = (doc/:abbr).inner_html
        self.route_id     = (doc/:routeid).inner_html
        self.number       = (doc/:number).inner_html
        self.color        = (doc/:color).inner_html
      end

      def info(options={})
        RouteInfo.new(number, options)
      end

      def schedule(options={})
        Schedule::RouteSchedule.new(number, options)
      end
    end

    class RouteInfo
      attr_accessor :route_number, :schedule_number, :date, :name, :abbreviation,
        :route_id, :origin, :destination, :color, :holidays, :stations

      def initialize(number, options={})
        self.route_number = number
        load_options(options)

        download_options = {
          :action => 'route',
          :cmd => 'routeinfo',
          :route => route_number,
        }
        download_options[:sched]  = schedule_number
        download_options[:date]   = date

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.schedule_number  = (data/:sched_num).inner_html
        self.name             = (data/:route/:name).inner_html
        self.abbreviation     = (data/:route/:abbr).inner_html
        self.route_number     = (data/:route/:number).inner_html
        self.origin           = (data/:route/:origin).inner_html
        self.destination      = (data/:route/:destination).inner_html
        self.color            = (data/:route/:color).inner_html
        self.holidays         = (data/:route/:holidays).inner_html
        self.stations         = (data/:route/:config/:station).map(&:inner_html)
      end

      private
      def load_options(options)
        self.schedule_number  = options.delete(:schedule_number)
        self.date             = options.delete(:date)

        Util.validate_date(date)
      end
    end

  end
end
