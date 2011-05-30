module Bort
  module Schedule
    def self.trips_by_arrival(orig, dest, options={})
      Trips.new('arrive', orig, dest, options).trips
    end

    def self.trips_by_departure(orig, dest, options={})
      Trips.new('depart', orig, dest, options).trips
    end

    class Trips
      attr_accessor :origin, :destination, :time, :date, :before, :after,
        :legend, :schedule_number, :trips

      def initialize(command, orig, dest, options={})
        self.origin = orig
        self.destination = dest
        load_options(options)

        download_options = {
          :action => 'sched',
          :cmd    => command,
          :orig   => origin,
          :dest   => destination,
          :time   => time,
          :date   => date,
          :b      => before,
          :a      => after,
          :l      => legend,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.date             = Date.parse((data/:date).inner_html)
        self.time             = Time.parse("#{(data/:date).inner_html} #{(data/:time).inner_html}")
        self.before           = (data/:before).inner_html.to_i
        self.after            = (data/:after).inner_html.to_i
        self.legend           = (data/:legend).inner_html
        self.schedule_number  = (data/:sched_num).inner_html
        self.trips            = (data/:trip).map{|trip| Trip.parse(trip)}
      end

      private
      def load_options(options)
        self.time   = options.delete(:time)
        self.date   = options.delete(:date)
        self.legend = options.delete(:legend)
        self.before = options.delete(:before)
        self.after  = options.delete(:after)

        Util.validate_time(time)
        Util.validate_date(date)

        self.legend = [[0, legend.to_i].max, 1].min unless legend.nil?
        self.before = [[0, before.to_i].max, 4].min unless before.nil?
        self.after  = [[0, after.to_i].max,  4].min unless after.nil?
      end
    end

    class Trip
      attr_accessor :origin, :destination, :fare, :origin_time, :origin_date,
        :destination_time, :destination_date, :legs

      def self.parse(doc)
        trip                  = Trip.new
        trip.origin           = doc.attributes['origin']
        trip.destination      = doc.attributes['destination']
        trip.fare             = doc.attributes['fare'].to_f
        trip.origin_date      = Date.parse(doc.attributes['origtimedate'])
        trip.destination_date = Date.parse(doc.attributes['desttimedate'])
        trip.origin_time      = Time.parse("#{doc.attributes['origtimedate']} #{doc.attributes['origtimemin']}")
        trip.destination_time = Time.parse("#{doc.attributes['desttimedate']} #{doc.attributes['desttimemin']}")
        trip.legs             = (doc/:leg).map{|leg| Leg.parse(leg)}

        trip
      end
    end

    class Leg
      attr_accessor :order, :transfer_code, :origin, :destination,
        :origin_time, :origin_date, :destination_time, :destination_date,
        :line, :bikeflag, :train_head_station

      def self.parse(doc)
        leg                     = Leg.new
        leg.order               = doc.attributes['order'].to_i
        leg.transfer_code       = doc.attributes['transfercode']
        leg.origin              = doc.attributes['origin']
        leg.destination         = doc.attributes['destination']
        leg.origin_date         = Date.parse(doc.attributes['origtimedate'])
        leg.destination_date    = Date.parse(doc.attributes['desttimedate'])
        leg.origin_time         = Time.parse("#{doc.attributes['origtimedate']} #{doc.attributes['origtimemin']}")
        leg.destination_time    = Time.parse("#{doc.attributes['desttimedate']} #{doc.attributes['desttimemin']}")
        leg.line                = doc.attributes['line']
        leg.bikeflag            = doc.attributes['bikeflag'] == '1'
        leg.train_head_station  = doc.attributes['trainheadstation']

        leg
      end
    end

    def self.fare(orig, dest, options={})
      Fare.new(orig, dest, options).fare
    end

    class Fare
      attr_accessor :origin, :destination, :date, :schedule_number, :fare

      def initialize(orig, dest, options={})
        self.origin = orig
        self.destination = dest
        load_options(options)

        download_options = {
          :action => 'sched',
          :cmd    => 'fare',
          :orig   => origin,
          :dest   => destination,
          :date   => date,
          :sched  => schedule_number,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.schedule_number  = (data/:sched_num).inner_html.to_i
        self.fare             = (data/:fare).inner_html.to_f
      end

      private
      def load_options(options)
        self.date             = options.delete(:date)
        self.schedule_number  = options.delete(:schedule_number)

        Util.validate_date(date)
      end
    end

    def self.holidays
      download_options = {
        :action => 'sched',
        :cmd    => 'holiday',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      (data/:holiday).map{|holiday|HolidayData.parse(holiday)}
    end

    class HolidayData
      attr_accessor :name, :date, :schedule_type

      def self.parse(doc)
        data                = HolidayData.new
        data.name           = (doc/:name).inner_html
        data.date           = Date.parse((doc/:date).inner_html)
        data.schedule_type  = (doc/:schedule_type).inner_html

        data
      end
    end

    class RouteSchedule
      attr_accessor :route_number, :schedule_number, :date, :legend, :trains

      def initialize(route_num, options={})
        self.route_number = route_num
        load_options(options)

        download_options = {
          :action => 'sched',
          :cmd    => 'routesched',
          :route  => route_number,
          :sched  => schedule_number,
          :date   => date,
          :l      => legend,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.date             = Date.parse((data/:date).inner_html)
        self.schedule_number  = (data/:sched_num).inner_html.to_i
        self.trains           = (data/:train).map{|train| TrainSchedule.parse(train, date)}
        self.legend           = (data/:legend).inner_html
      end

      private
      def load_options(options)
        self.date             = options.delete(:date)
        self.schedule_number  = options.delete(:schedule_number)
        self.legend           = options.delete(:legend)
        self.date             = options.delete(:date)

        Util.validate_date(date)
      end
    end

    class TrainSchedule
      attr_accessor :stops, :index

      def self.parse(doc, date)
        schedule        = TrainSchedule.new
        schedule.index  = doc.attributes['index'].to_i
        schedule.stops  = (doc/:stop).map{|stop| Stop.parse(stop, date)}

        schedule
      end
    end

    class Stop
      attr_accessor :station, :origin_time, :bikeflag

      def self.parse(doc, date)
        stop              = Stop.new
        stop.station      = doc.attributes['station']
        stop.origin_time  = Time.parse("#{date.to_s} #{doc.attributes['origtime']}")
        stop.bikeflag     = doc.attributes['bikeflag'] == '1'

        stop
      end
    end

    def self.schedules
      download_options = {
        :action => 'sched',
        :cmd    => 'scheds',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      (data/:schedule).map{|schedule| Schedule.parse(schedule)}
    end

    class Schedule
      attr_accessor :schedule_id, :effective_date

      def self.parse(doc)
        schedule                = Schedule.new
        schedule.schedule_id    = doc.attributes['id'].to_i
        schedule.effective_date = Time.parse(doc.attributes['effectivedate'])

        schedule
      end
    end

    def self.special_schedules(print_legend=false)
      download_options = {
        :action => 'sched',
        :cmd    => 'special',
        :l      => print_legend ? '1' : '0',
      }

      xml = Util.download(download_options)
      data = Hpricot(xml)

      puts (data/:legend).inner_html if print_legend

      (data/:special_schedule).map{|special| SpecialSchedule.parse(special)}
    end

    class SpecialSchedule
      attr_accessor :start_date, :end_date, :start_time, :end_time,
        :text, :link, :origin, :destination, :day_of_week, :routes_affected

      def self.parse(doc)
        schedule                  = SpecialSchedule.new
        schedule.start_date       = Date.parse((doc/:start_date).inner_html)
        schedule.end_date         = Date.parse((doc/:end_date).inner_html)
        schedule.start_time       = Time.parse("#{schedule.start_date.to_s} #{(doc/:start_time).inner_html}")
        schedule.end_time         = Time.parse("#{schedule.end_date.to_s} #{(doc/:end_time).inner_html}")
        schedule.text             = (doc/:text).inner_html
        schedule.link             = (doc/:link).inner_html
        schedule.origin           = (doc/:orig).inner_html
        schedule.destination      = (doc/:dest).inner_html
        schedule.day_of_week      = (doc/:day_of_week).inner_html.split(',').map(&:to_i)
        schedule.routes_affected  = (doc/:routes_affected).inner_html.split(',')

        schedule
      end
    end

    class StationSchedule
      attr_accessor :origin, :date, :schedule_number, :name, :abbreviation, :schedules, :legend

      def initialize(origin, options={})
        load_options(options)

        download_options = {
          :action => 'sched',
          :cmd    => 'special',
          :org    => origin,
          :date   => date,
          :l      => legend,
        }

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.date             = Date.parse((data/:date).inner_html)
        self.schedule_number  = (data/:sched_num).inner_html.to_i
        self.name             = (data/:name).inner_html
        self.abbreviation     = (data/:abbr).inner_html
        self.legend           = (data/:legend).inner_html
        self.schedules        = (data/:station/:item).map{|line| StationLine.parse(line, date)}
      end

      private
      def load_options(options)
        self.date   = options.delete(:date)
        self.legend = options.delete(:legend)

        Util.validate_date(date)
      end
    end

    class StationLine

      attr_accessor :name, :train_head_station, :origin_time, :destination_time, :index, :bikeflag
      def self.parse(doc, date)
        line                    = StationLine.new
        line.name               = doc.attributes['line']
        line.train_head_station = doc.attributes['trainheadstation']
        line.origin_time        = Time.parse("#{date} #{doc.attributes['origtime']}")
        line.destination_time   = Time.parse("#{date} #{doc.attributes['desttime']}")
        line.index              = doc.attributes['trainidx'].to_i
        line.bikeflag           = doc.attributes['bikeflag'] == '1'

        line
      end
    end

  end
end
