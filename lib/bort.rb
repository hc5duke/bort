require 'net/http'
require 'time'
require 'date'
require 'hpricot'
require 'bort/realtime'
require 'bort/route'
require 'bort/schedule'
require 'bort/station'

module Bort
  def self.Bort(key)
    Util.set_key(key)
  end
  def Bort(key); Bort::Bort(key); end

  # shortcuts
  def self.estimates(orig, options={})
    Realtime::Estimates.new(orig, options)
  end

  def self.routes(options={})
    Route.routes(options)
  end

  def self.route_info(route_number, options={})
    Route::Info.new(route_number, options)
  end

  def self.trips(orig, dest, options={})
    command = options.delete(:by) { 'arrive' }
    Schedule::Trips.new(command, orig, dest, options).trips
  end

  def self.fare(orig, dest, options={})
    Schedule::fare(orig, dest, options)
  end

  def self.schedules
    Schedule.schedules
  end

  def self.schedule_at(abbreviation, options={})
    Schedule::StationSchedule.new(abbreviation, options).schedules
  end

  def self.stations
    Station.stations
  end

  def self.station_info(abbreviation)
    Station.info(abbreviation)
  end

  class Util
    def self.set_key(key)
      @@api_key = key
    end

    def self.download(params)
      params[:key] = @@api_key
      action    = params.delete(:action)

      queries   = params.delete_if{|k, v|v.nil?}.map{|k, v| "#{k}=#{v}" }.join('&')
      request   = Net::HTTP::Get.new("/api/#{action}.aspx?#{queries}")
      response  = Net::HTTP.start('api.bart.gov') do |http|
        http.request(request)
      end

      response.body
    end

    # param validation
    VALID_AM_PM       = ['am', 'pm', nil]
    VALID_DATE_STRING = ['today', 'now', nil]

    def self.validate_time(time)
      return unless time

      hm, ap = time.split('+')
      hh, mm = hm.split(':').map(&:to_i)

      unless /^\d{1,2}:\d{1,2}+\w\w$/ === time &&
        VALID_AM_PM.include?(ap.downcase) &&
        (1..12) === hh &&
        (0..59) === mm

        raise InvalidTime.new(time)
      end
    end

    def self.validate_date(date)
      return if VALID_DATE_STRING.include?(date)

      mm, dd, yyyy = date.split('/').map(&:to_i)
      year = Time.now.year

      unless /^\d{1,2}\/\d{1,2}\/\d{4}$/ === date &&
        (1..12) === mm &&
        (1..31) === dd &&
        (year-1..year+1) === yyyy

        raise InvalidDate.new(date)
      end
    end

    def self.validate_station(station)
      raise InvalidStation.new(station) unless STATIONS.keys.map(&:to_s).include?(station.to_s.downcase)
    end
  end

  STATIONS = {
    :"12th" => "12th St. Oakland City Center",
    :"16th" => "16th St. Mission (SF)",
    :"19th" => "19th St. Oakland",
    :"24th" => "24th St. Mission (SF)",
    :ashb   => "Ashby (Berkeley)",
    :balb   => "Balboa Park (SF)",
    :bayf   => "Bay Fair (San Leandro)",
    :cast   => "Castro Valley",
    :civc   => "Civic Center (SF)",
    :cols   => "Coliseum/Oakland Airport",
    :colm   => "Colma",
    :conc   => "Concord",
    :daly   => "Daly City",
    :dbrk   => "Downtown Berkeley",
    :dubl   => "Dublin/Pleasanton",
    :deln   => "El Cerrito del Norte",
    :plza   => "El Cerrito Plaza",
    :embr   => "Embarcadero (SF)",
    :frmt   => "Fremont",
    :ftvl   => "Fruitvale (Oakland)",
    :glen   => "Glen Park (SF)",
    :hayw   => "Hayward",
    :lafy   => "Lafayette",
    :lake   => "Lake Merritt (Oakland)",
    :mcar   => "MacArthur (Oakland)",
    :mlbr   => "Millbrae",
    :mont   => "Montgomery St. (SF)",
    :nbrk   => "North Berkeley",
    :ncon   => "North Concord/Martinez",
    :orin   => "Orinda",
    :pitt   => "Pittsburg/Bay Point",
    :phil   => "Pleasant Hill",
    :powl   => "Powell St. (SF)",
    :rich   => "Richmond",
    :rock   => "Rockridge (Oakland)",
    :sbrn   => "San Bruno",
    :sfia   => "San Francisco Int'l Airport",
    :sanl   => "San Leandro",
    :shay   => "South Hayward",
    :ssan   => "South San Francisco",
    :ucty   => "Union City",
    :wcrk   => "Walnut Creek",
    :woak   => "West Oakland",
  }

  class InvalidDate < RuntimeError; end
  class InvalidTime < RuntimeError; end
  class InvalidStation < RuntimeError; end
end
