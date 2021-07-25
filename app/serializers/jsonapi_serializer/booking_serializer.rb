module JsonapiSerializer
  class BookingSerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :no_of_seats
    attribute :seat_price
    attribute :flight_id
    attribute :user_id
  end
end
