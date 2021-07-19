# RSpec.describe OpenWeatherMap::City, :city do
#   it 'initialises values correctly' do
#     city = described_class.new(id: 2_172_797, lat: -16.92, lon: 145.77, name: 'Cairns',
#                                temp_k: 300.15)

#     expect(city.id).to eq(2_172_797)
#     expect(city.lat).to eq(-16.92)
#     expect(city.lon).to eq(145.77)
#     expect(city.name).to eq('Cairns')
#   end

#   describe '#temp' do
#     it 'correctly converts temperature' do
#       city1 = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'Test1',
#                                   temp_k: 270.17211)
#       city2 = described_class.new(id: 2, lat: -16.92, lon: 145.78, name: 'Test2',
#                                   temp_k: 300.15)
#       city3 = described_class.new(id: 2, lat: -16.92, lon: 145.78, name: 'Test3',
#                                   temp_k: 307.3289)

#       expect(city1.temp).to eq(-2.98)
#       expect(city2.temp).to eq(27.0)
#       expect(city3.temp).to eq(34.18)
#     end
#   end

#   it 'correctly compares objects with different temperature' do
#     receiver = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'A', temp_k: 270.17211)
#     other = described_class.new(id: 2, lat: -16.92, lon: 145.77, name: 'B', temp_k: 300.17211)
#     expect(receiver < other).to eq(true)

#     receiver = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'A', temp_k: 303.15)
#     other = described_class.new(id: 2, lat: -16.92, lon: 145.77, name: 'B', temp_k: 273.15)
#     expect(receiver > other).to eq(true)
#   end

#   it 'correctly compares objects with the same temperature' do
#     receiver = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'A', temp_k: 300.15)
#     other = described_class.new(id: 2, lat: -16.92, lon: 145.77, name: 'B', temp_k: 300.15)
#     expect(receiver < other).to eq(true)

#     receiver = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'A', temp_k: 300.15)
#     other = described_class.new(id: 2, lat: -16.92, lon: 145.77, name: 'A', temp_k: 300.15)
#     expect(receiver == other).to eq(true)

#     receiver = described_class.new(id: 1, lat: -16.92, lon: 145.77, name: 'B', temp_k: 300.15)
#     other = described_class.new(id: 2, lat: -16.92, lon: 145.77, name: 'A', temp_k: 300.15)
#     expect(receiver > other).to eq(true)
#   end

#   describe '#City.parse' do
#     it 'correctly initialises returned instance' do
#       city = described_class.parse({ 'coord' => { 'lat' => 145.77, 'lon' => -16.92 },
#                                      'main' => { 'temp' => 300.15 }, 'id' => 2_172_797,
#                                      'name' => 'Cairns' })
#       expect(city.id).to eq(2_172_797)
#       expect(city.lat).to eq(145.77)
#       expect(city.lon).to eq(-16.92)
#       expect(city.name).to eq('Cairns')
#       expect(city.temp).to eq(27.0)
#     end
#   end
# end
