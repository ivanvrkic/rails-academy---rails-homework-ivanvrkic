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
  end
end
