module OpenWeatherMap
  class City
    include Comparable
    attr_reader :id, :lat, :lon, :name, :temp_k

    def initialize(id:, lat:, lon:, name:, **args)
      @id = id
      @lat = lat
      @lon = lon
      @name = name
      @temp_k = args[:temp_k]
      @weather = args[:weather]
    end

    def <=>(other)
      return temp <=> other.temp unless temp == other.temp

      name <=> other.name
    end

    def temp
      (temp_k - 273.15).round(2)
    end

    def self.parse(response)
      new(id: response['id'], lat: response.dig('coord', 'lat'), lon: response.dig('coord', 'lon'),
          name: response['name'], temp_k: response.dig('main', 'temp'),
          weather: response.dig('weather', 0, 'main'))
    end

    def nearby(count = 5)
      count = 50 if count > 50
      url_params = "/find?lat=#{@lat}&lon=#{@lon}&cnt=#{count}&appid=#{API_KEY}"
      response = Faraday.new(url: BASE_URL).get(URL_PATH + url_params)
      JSON.parse(response.body)['list'].map { |c| City.parse(c) }.sort
    end

    def coldest_nearby(*args)
      nearby(*args).min
    end
  end
end
