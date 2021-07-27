module JsonapiSerializer
  class CompanySerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :name
    attribute :created_at
    attribute :updated_at

    has_many :flights
  end
end
