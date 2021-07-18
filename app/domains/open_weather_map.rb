require 'json'
require 'faraday'
module OpenWeatherMap
  def self.city(city_name)
    id = Resolver.city_id(city_name)
    return nil if id.nil?

    url = "https://api.openweathermap.org/data/2.5/weather?id=#{id}&appid=#{Rails.application.credentials.open_weather_map_api_key}"
    response = Faraday.get(url)
    City.parse(JSON.parse(response.body))
  end

  def self.cities(city_names)
    city_names.map { |c| city(c) }.compact
  end
end
