module OpenWeatherMap
  class City
    include Comparable
    attr_reader :id, :lat, :lon, :name

    def initialize(id:, lat:, lon:, name:, temp_k:)
      @id = id
      @lat = lat
      @lon = lon
      @name = name
      @temp_k = temp_k
    end

    def <=>(other)
      return temp <=> other.temp unless temp == other.temp

      name <=> other.name
    end

    def temp
      (@temp_k - 273.15).round(2)
    end
  end
end
