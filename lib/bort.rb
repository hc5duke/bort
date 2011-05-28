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
  def self.departures(orig, options={});               Realtime::Etd.new(orig, options); end
  def self.by_arrival_time(orig, dest, options={});    Schedule::Arrive.new(orig, dest, options); end
  def self.by_departure_time(orig, dest, options={});  Schedule::Depart.new(orig, dest, options); end

  class Util
    def self.set_key(key)
      @@api_key = key
    end

    def self.download(params)
      params[:key] = @@api_key
      action    = params.delete(:action)

      queries   = params.map{|k, v| "#{k}=#{v}" }.join('&')
      request   = Net::HTTP::Get.new("/api/#{action}.aspx?#{queries}")
      response  = Net::HTTP.start('api.bart.gov') do |http|
        http.request(request)
      end

      response.body
    end

    def self.stations; @@stations; end

    @@stations = {
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
  end
end
