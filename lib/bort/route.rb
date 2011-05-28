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
        download_options[:sched]  = schedule  if schedule
        download_options[:date]   = date      if date

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

        unless date.nil?
          return if %w(today now).include?(date)
          mm    = date[0,2].to_i
          dd    = date[3,2].to_i
          yyyy  = date[6,4].to_i
          year = Time.now.year

          raise InvalidDate.new(date) unless (1..12) === mm && (1..31) === dd && (year..year+1) === yyyy
        end
      end
    end

    class Route
      attr_accessor :name, :abbreviation, :route_id, :number, :color
      def initialize(doc)
        self.name         = (doc/:name).inner_html
        self.abbreviation = (doc/:abbr).inner_html
        self.route_id     = (doc/:route_id).inner_html
        self.number       = (doc/:number).inner_html
        self.color        = (doc/:color).inner_html
      end
    end

    class InvalidDate < RuntimeError; end

  end
end
