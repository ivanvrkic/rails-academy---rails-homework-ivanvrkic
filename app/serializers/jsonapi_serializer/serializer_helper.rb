module JsonapiSerializer
  module SerializerHelper
    def json_with_root
      data = serializable_hash[:data]
      { data_type(data) => data_attributes(data) }.to_json
    end

    def json_without_root
      data = serializable_hash[:data]
      data_attributes(data).to_json
    end

    private

    def data_attributes(data)
      data.is_a?(Hash) ? data[:attributes] : data.map { |object| object[:attributes] }
    end

    def data_type(data)
      data.is_a?(Hash) ? data[:type].to_s : data[0][:type].to_s.pluralize
    end
  end
end
