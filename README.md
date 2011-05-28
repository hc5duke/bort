Another BART API ruby wrapper.

## Usage

Departure times

    require 'bort'
    Bort::Bort('MW9S-E7SL-26DU-VV8V') # set your own API key here

    estimates = Bort.departures('dubl') # same as Bort::Realtime::Etd.new('dubl')
    estimates.etds.first.destination
    # => "Daly City"
    estimates.etds.first.estimates.first.color
    # => "BLUE"
    estimates.etds.first.estimates.map(&:minutes)
    # => [8, 25]
