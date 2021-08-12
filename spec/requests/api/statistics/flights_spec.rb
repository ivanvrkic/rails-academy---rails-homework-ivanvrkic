RSpec.describe 'Statistics/Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user_admin) { create(:user, role: 'admin') }

  describe 'GET /api/statistics/flights' do
    let!(:flight) { create(:flight) }

    context 'when flight has bookings' do
      let!(:bookings) { create_list(:booking, 3, flight_id: flight.id) }

      it 'matches schema' do
        get '/api/statistics/flights',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]).to include('flight_id' => anything,
                                                   'no_of_booked_seats' => anything,
                                                   'occupancy' => anything,
                                                   'revenue' => anything)
      end

      it 'calculates revenue' do
        get '/api/statistics/flights',
            headers: api_headers.merge({ Authorization: user_admin.token })

        revenue = bookings.sum { |b| b.no_of_seats * b.seat_price }

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]['revenue']).to eq(revenue)
      end

      it 'calculates number of booked seats' do
        get '/api/statistics/flights',
            headers: api_headers.merge({ Authorization: user_admin.token })

        no_of_booked_seats = bookings.sum(&:no_of_seats)

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]['no_of_booked_seats']).to eq(no_of_booked_seats)
      end

      it 'calculates occupancy' do
        get '/api/statistics/flights',
            headers: api_headers.merge({ Authorization: user_admin.token })

        occupancy = "#{bookings.sum(&:no_of_seats) / flight.no_of_seats.to_d * 100}%"

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]['occupancy']).to eq(occupancy)
      end
    end

    context 'when flight does not have bookings' do
      it 'returns an empty flight list' do
        get '/api/statistics/flights',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]).to include('flight_id' => flight.id,
                                                   'no_of_booked_seats' => 0,
                                                   'occupancy' => '0.0%',
                                                   'revenue' => 0)
      end
    end
  end
end
