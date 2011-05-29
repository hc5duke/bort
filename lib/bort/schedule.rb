module Bort
  module Schedule
    class ByTime
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
        }
        download_options[:time] = time    if time
        download_options[:date] = date    if date
        download_options[:b]    = before  if before
        download_options[:a]    = after   if after
        download_options[:l]    = legend  if legend

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.date             = Date.parse((data/:date).inner_html)
        self.time             = Time.parse("#{(data/:date).inner_html} #{(data/:time).inner_html}")
        self.before           = (data/:before).inner_html.to_i
        self.after            = (data/:after).inner_html.to_i
        self.legend           = (data/:legend).inner_html
        self.schedule_number  = (data/:sched_num).inner_html
        self.trips = (data/:trip).map{|trip| Trip.new(trip)}
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

    class Arrive < ByTime
      def initialize(orig, dest, options={})
        super('arrive', orig, dest, options)
      end
    end

    class Depart < ByTime
      def initialize(orig, dest, options={})
        super('depart', orig, dest, options)
      end
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

    class Trip
      attr_accessor :origin, :destination, :fare, :origin_time, :origin_date,
        :destination_time, :destination_date, :legs
      def initialize(doc)
        self.origin           = doc.attributes['origin']
        self.destination      = doc.attributes['destination']
        self.fare             = doc.attributes['fare'].to_f
        self.origin_date      = Date.parse(doc.attributes['origtimedate'])
        self.destination_date = Date.parse(doc.attributes['desttimedate'])
        self.origin_time      = Time.parse("#{doc.attributes['origtimedate']} #{doc.attributes['origtimemin']}")
        self.destination_time = Time.parse("#{doc.attributes['desttimedate']} #{doc.attributes['desttimemin']}")
        self.legs             = (doc/:leg).map{|leg| Leg.new(leg)}
      end
    end

    class Leg
      attr_accessor :order, :transfer_code, :origin, :destination,
        :origin_time, :origin_date, :destination_time, :destination_date,
        :line, :bikeflag, :train_head_station
      def initialize(doc)
        self.order              = doc.attributes['order'].to_i
        self.transfer_code      = doc.attributes['transfercode']
        self.origin             = doc.attributes['origin']
        self.destination        = doc.attributes['destination']
        self.origin_date        = Date.parse(doc.attributes['origtimedate'])
        self.destination_date   = Date.parse(doc.attributes['desttimedate'])
        self.origin_time        = Time.parse("#{doc.attributes['origtimedate']} #{doc.attributes['origtimemin']}")
        self.destination_time   = Time.parse("#{doc.attributes['desttimedate']} #{doc.attributes['desttimemin']}")
        self.line               = doc.attributes['line']
        self.bikeflag           = doc.attributes['bikeflag'] == '1'
        self.train_head_station = doc.attributes['trainheadstation']
      end
    end
  end
end
