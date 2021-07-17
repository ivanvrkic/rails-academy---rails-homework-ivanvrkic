require 'json'

module OpenWeatherMap
  class Resolver
    class << Resolver
      def city_id(city_name)
        city_file = File.open(File.expand_path('city_ids.json', __dir__))
        cities = JSON.parse(city_file.read)
        city = cities.find { |c| c['name'] == city_name }
        return city if city.nil?

        city['id']
      end
    end
  end
end
