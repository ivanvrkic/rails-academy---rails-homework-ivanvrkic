module OpenWeatherMap
  class Resolver
    def self.city_id(city_name)
      city_file = open('city_ids.json')
      city = parse(city_file).find { |c| c['name'] == city_name }
      return city if city.nil?

      city['id']
    end

    def self.open(file_name)
      File.open(File.expand_path(file_name, __dir__))
    end

    def self.parse(file)
      JSON.parse(file.read)
    end
  end
end
