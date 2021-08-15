module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end

    def by_id
      proc { |x| x['id'] }
    end

    def api_headers(default_serializer: true, not_root: false)
      headers = { 'Content-Type': 'application/json',
                  'Accept': 'application/json' }
      headers = { 'HTTP_X_API_SERIALIZER_ROOT': '0' }.merge(headers) if not_root

      return headers if default_serializer

      { 'HTTP_X_API_SERIALIZER': 'jsonapi-serializer' }.merge(headers)
    end
  end
end
