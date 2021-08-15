RSpec.describe 'Statistics/Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user_admin) { create(:user, role: 'admin') }

  describe 'GET /api/statistics/companies' do
    let!(:company) { create(:company) }

    context 'when flights have bookings' do
      let!(:flight) { create(:flight) }
      let!(:total_revenue) do
        create_list(:booking, 3, flight: flight)
        company.flights.sum { |f| f.bookings.sum { |b| b.no_of_seats * b.seat_price } }
      end
      let!(:total_booked_seats) do
        company.flights.sum { |f| f.bookings.sum(:no_of_seats) }
      end

      it 'matches schema' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]).to include('company_id' => anything,
                                                     'average_price_of_seats' => anything,
                                                     'total_no_of_booked_seats' => anything,
                                                     'total_revenue' => anything)
      end

      it 'calculates total revenue' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: user_admin.token })
        binding.pry
        expect(response).to have_http_status(:ok)
        expect(json_body['companies']).to eq(total_revenue)
      end

      it 'calculates total number of booked seats' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]['total_no_of_booked_seats']).to eq(total_booked_seats)
      end

      it 'calculates average price of seats' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: user_admin.token })

        avg_price_of_seats = total_booked_seats==0 ? 0 : total_revenue / total_booked_seats.to_f
        binding.pry
        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]['average_price_of_seats']).to eq(avg_price_of_seats)
      end
    end

    context 'when flights do not have any bookings' do
      it 'returns an empty company list' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]).to include('company_id' => company.id,
                                                     'average_price_of_seats' => 0.0,
                                                     'total_no_of_booked_seats' => 0,
                                                     'total_revenue' => 0)
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        get '/api/statistics/companies',
            headers: api_headers.merge({ Authorization: create(:user).token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        get '/api/statistics/companies',
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end
end
