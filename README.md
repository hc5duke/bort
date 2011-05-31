Comprehensive BART API ruby wrapper.

## Usage

Set up API key

    require 'bort'
    Bort::Bort('MW9S-E7SL-26DU-VV8V') # set your own API key here

Real-time data

    trains = Bort.trains_near('mont', :color => 'blue', :direction => 'n')
    => ... # trains near Montgomery station going Northbound on the blue line

Schedule &amp; planning trips

    routes = Bort.routes
    => ... # all routes

    Bort.route(1)
    => ... # info for route #1

    Bort.trips('dubl', 'mont', :date => '6/10/2011', :time => '09:00+AM')
    => ... # trips from Dublin/Pleasanton to Montgomery on 6/10 around 9 AM

    Bort.fare('dubl', 'mont')
    => 5.55

    Bort.schedules
    => ... # all known schedules

    Bort.schedule_at('mont')
    => ... # schedule at Montgomery for today

Station data

    Bort.stations
    => ... # all 44 stations and partial info on them

    Bort.station_info('mont')
    => ... # more info on Montgomery station
