class BookingSerializer < Blueprinter::Base
  identifier :id

  field :no_of_seats
  field :seat_price
  field :created_at
  field :updated_at

  view :normal do
    association :flight, blueprint: FlightSerializer
    association :user, blueprint: UserSerializer
  end
end
