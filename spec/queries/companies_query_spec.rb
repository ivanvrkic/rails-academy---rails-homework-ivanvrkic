RSpec.describe CompaniesQuery, type: :query do
  let!(:companies) { create_list(:company, 3) }
  let!(:total_revenue) do
    flights = create_list(:flight, 3, company: companies[0])
    create_list(:booking, 3, flight: flights[0])
    create_list(:booking, 3, flight: flights[1])
    companies[0].flights.sum { |f| f.bookings.sum { |b| b.no_of_seats * b.seat_price } }
  end
  let!(:total_booked_seats) do
    companies[0].flights.sum { |f| f.bookings.sum(:no_of_seats) }
  end
  let(:query) { described_class.new.with_stats.find(companies[0].id) }

  it 'returns statistics of the companies' do
    query = described_class.new.with_stats

    expect(query.length).to eq(companies.count)
  end

  it 'calculates total revenue' do
    expect(query.total_revenue).to eq(total_revenue)
  end

  it 'calculates total number of booked seats' do
    expect(query.total_no_of_booked_seats).to eq(total_booked_seats)
  end

  it 'calculates average price of seats' do
    average_price_of_seats = total_revenue / total_booked_seats
    expect(query.average_price_of_seats).to eq(average_price_of_seats)
  end
end
