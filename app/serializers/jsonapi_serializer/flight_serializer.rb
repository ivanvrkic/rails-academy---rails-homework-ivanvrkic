module JsonapiSerializer
  class FlightSerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :name
    attribute :no_of_seats
    attribute :base_price
    attribute :departs_at
    attribute :arrives_at
    attribute :company_id
    attribute :created_at
    attribute :updated_at
  end
end
