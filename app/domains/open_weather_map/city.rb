module OpenWeatherMap
  class City
    include Comparable
    attr_reader :id, :lat, :lon, :name

    def initialize(id:, lat:, lon:, name:, temp_k:, weather:)
      @id = id
      @lat = lat
      @lon = lon
      @name = name
      @temp_k = temp_k
      @weather = weather
    end

    def <=>(other)
      return temp <=> other.temp unless temp == other.temp

      name <=> other.name
    end

    def temp
      (@temp_k - 273.15).round(2)
    end

    def self.parse(response)
      new(id: response['id'], lat: response['coord']['lat'], lon: response['coord']['lon'],
          name: response['name'], temp_k: response['main']['temp'], weather: response['weather'][0]['main'])
    end

    def nearby(count = 5)
      count = 49 if count > 49
      url = "https://api.openweathermap.org/data/2.5/find?lat=#{@lat}&lon=#{@lon}&cnt=#{count + 1}&appid=#{Rails.application.credentials.open_weather_map_api_key}"
      response = Faraday.get(url)
      JSON.parse(response.body)['list'].map { |c| City.parse(c) }.drop(1).sort
    end

    def coldest_nearby(count = 5)
      nearby(count)[0]
    end
  end
end
