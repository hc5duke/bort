Another BART API ruby wrapper.

## Usage

Departure times

    require 'bort'
    include Bort
    Bort('MW9S-E7SL-26DU-VV8V') # set your own API key here

    estimates = Realtime::Etd.new('dubl')
    estimates.etds.destination
    # => "Daly City"
    estimates.etds.estimates.first.color
    # => "blue"
    estimates.etds.estimates.first.minutes
    # => 3
    station.name
    # => "South San Francisco"

