class FlightSerializer < Blueprinter::Base
  identifier :id
  field :no_of_seats
  field :seat_price
  field :flight_id
  field :user_id
end
