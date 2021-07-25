module JsonapiSerializer
  class CompanySerializer
    include JSONAPI::Serializer
    include SerializerHelper

    attribute :id
    attribute :name
  end
end
