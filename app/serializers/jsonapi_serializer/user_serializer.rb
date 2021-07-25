module JsonapiSerializer
  class UserSerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :first_name
    attribute :last_name
    attribute :email
  end
end
