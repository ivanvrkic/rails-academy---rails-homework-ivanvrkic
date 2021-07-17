RSpec.describe Resolver, :resolver do
  it 'returns correct id for a known city' do
    expect(OpenWeatherMap::Resolver.city_id('Zagreb')).to eq(3_186_886)
    expect(OpenWeatherMap::Resolver.city_id('New York')).to eq(5_128_638)
    expect(OpenWeatherMap::Resolver.city_id('Frankfurt am Main')).to eq(2_925_533)
  end

  it 'returns nil for unknown city' do
    expect(OpenWeatherMap::Resolver.city_id('Zabreg')).to eq(nil)
    expect(OpenWeatherMap::Resolver.city_id('xxxxx')).to eq(nil)
  end
end
