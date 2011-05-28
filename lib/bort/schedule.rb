module Bort
  module Schedule
    class Arrive
      attr_accessor :origin, :destination, :time, :date, :before, :after,
        :legend, :schedule_number, :trips

      def initialize(orig, dest, options={})
        self.origin = orig
        self.destination = dest
        load_options(options)

        download_options = {
          :action => 'sched',
          :cmd => 'arrive',
        }
        download_options[:orig] = origin
        download_options[:dest] = destination
        download_options[:time] = time    if time
        download_options[:date] = date    if date
        download_options[:b]    = before  if before
        download_options[:a]    = after   if after
        download_options[:l]    = legend  if legend

        xml = Util.download(download_options)
        data = Hpricot(xml)

        self.schedule_number = (data/:sched_num).inner_html
        self.trips = (data/:trip).map{|trip| Trip.new(trip)}
      end

      private
      def load_options(options)
      end
    end

    class Trip
      attr_accessor :origin, :destination, :fare, :origin_time, :origin_date,
        :destination_time, :destination_date, :legs
      def initialize(doc)
        self.origin           = (doc/:origin).inner_html
        self.destination      = (doc/:destination).inner_html
        self.fare             = (doc/:fare).inner_html
        self.origin_time      = (doc/:origTimeMin).inner_html
        self.origin_date      = (doc/:origTimeDate).inner_html
        self.destination_time = (doc/:destTimeMin).inner_html
        self.destination_date = (doc/:destTimeDate).inner_html
        self.legs             = (doc/:leg).map{|leg| Leg.new(leg)}
      end
    end

    class Leg
      attr_accessor :order, :transfer_code, :origin, :destination,
        :original_time, :original_date, :destination_time, :destimation_date,
        :line, :bikeflag, :train_head_station
      def initialize(leg)
        # TODO do stuff
      end
    end
  end
end
