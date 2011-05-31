module Bort
  module Route
    class Route
      attr_accessor :name, :abbreviation, :route_id, :number, :color
      def self.parse(doc)
        route = Route.new
        route.name         = (doc/:name).inner_text
        route.abbreviation = (doc/:abbr).inner_text
        route.route_id     = (doc/:routeid).inner_text
        route.number       = (doc/:number).inner_text.to_i
        route.color        = (doc/:color).inner_text

        route
      end

      def info(options={})
        Info.new(number, options)
      end

      def schedule(options={})
        Schedule::RouteSchedule.new(number, options)
      end

      def <=> other
        self.number <=> other.number
      end
    end

    def self.routes(options={})
      Routes.new(options).routes
    end

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

        self.schedule_number = (data/:sched_num).inner_text
        self.routes = (data/:route).map do |route|
          Route.parse(route)
        end.sort
      end

      private
      def load_options(options)
        self.schedule = options.delete(:schedule)
        # date does not appear to be supported by the current API
        self.date     = options.delete(:date)

        Util.validate_date(date)
      end
    end

    class Info
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

        self.schedule_number  = (data/:sched_num).inner_text
        self.name             = (data/:route/:name).inner_text
        self.abbreviation     = (data/:route/:abbr).inner_text
        self.route_number     = (data/:route/:number).inner_text
        self.origin           = (data/:route/:origin).inner_text
        self.destination      = (data/:route/:destination).inner_text
        self.color            = (data/:route/:color).inner_text
        self.holidays         = (data/:route/:holidays).inner_text
        self.stations         = (data/:route/:config/:station).map(&:inner_text)
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
