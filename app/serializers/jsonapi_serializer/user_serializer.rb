module JsonapiSerializer
  class UserSerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :first_name
    attribute :last_name
    attribute :email
    attribute :created_at
    attribute :updated_at
    attribute :role

    has_many :bookings
  end
end
