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
    ids=city_names.map { |city_name| Resolver.city_id(city_name) }.compact.join(",")
    url = "https://api.openweathermap.org/data/2.5/group?id=#{ids}&appid=#{Rails.application.credentials.open_weather_map_api_key}"
    response = Faraday.get(url)
    JSON.parse(response.body)['list'].map { |c| City.parse(c) }
  end
end
