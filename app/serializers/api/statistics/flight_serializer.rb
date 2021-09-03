module Api
  module Statistics
    class FlightSerializer < Blueprinter::Base
      identifier :id, name: :flight_id
      field :revenue
      field :no_of_booked_seats
      field :occupancy do |flight|
        "#{flight.occupancy * 100}%"
      end
    end
  end
end
