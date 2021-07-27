module JsonapiSerializer
  class BookingSerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :no_of_seats
    attribute :seat_price
    attribute :created_at
    attribute :updated_at

    belongs_to :flight
    belongs_to :user
  end
end
