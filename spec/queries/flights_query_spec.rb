RSpec.describe FlightsQuery, type: :query do
  let!(:flights) { create_list(:flight, 3) }
  let!(:bookings) { create_list(:booking, 3, flight_id: flights[0].id) }
  let(:query) { described_class.new.with_stats.find(flights[0].id) }

  it 'queries statistics of the flights' do
    query = described_class.new.with_stats

    expect(query.length).to eq(flights.count)
  end

  it 'calculates revenue' do
    revenue = bookings.sum { |b| b.no_of_seats * b.seat_price }

    expect(query.revenue).to eq(revenue)
  end

  it 'calculates number of booked seats' do
    no_of_booked_seats = bookings.sum(&:no_of_seats)

    expect(query.no_of_booked_seats).to eq(no_of_booked_seats)
  end

  it 'calculates occupancy' do
    occupancy = bookings.sum(&:no_of_seats) / flights[0].no_of_seats.to_d

    expect(query.occupancy).to eq(occupancy)
  end
end
