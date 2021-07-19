module OpenWeatherMap
  BASE_URL = 'https://api.openweathermap.org'.freeze
  URL_PATH = '/data/2.5'.freeze
  API_KEY=Rails.application.credentials.open_weather_map_api_key.freeze
  def self.city(city_name)
    id = Resolver.city_id(city_name)
    return if id.nil?

    url_params = "/weather?id=#{id}&appid=#{API_KEY}"
    response = Faraday.new(url: BASE_URL).get(URL_PATH + url_params)
    City.parse(JSON.parse(response.body))
  end

  def self.cities(city_names)
    ids = city_names.map { |city_name| Resolver.city_id(city_name) }.compact.join(',')
    url_params = "/group?id=#{ids}&appid=#{API_KEY}"
    response = Faraday.new(url: BASE_URL).get(URL_PATH + url_params)
    JSON.parse(response.body)['list'].map { |c| City.parse(c) }
  end
end
