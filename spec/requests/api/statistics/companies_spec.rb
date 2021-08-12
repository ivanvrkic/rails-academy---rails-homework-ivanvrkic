RSpec.describe 'Statistics/Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user_admin) { create(:user, role: 'admin') }

  describe 'GET /api/statistics/companies' do
    let!(:company) { create(:company) }

    context 'when flights have bookings' do
      let!(:flights) { create_list(:flight, 3, company: company) }
      let!(:total_revenue) do
        company.flights.sum { |f| f.bookings.sum { |b| b.no_of_seats * b.seat_price } }
      end
      let!(:total_booked_seats) do
        company.flights.sum { |f| f.bookings.sum(&:no_of_seats) }
      end

      before do
        create_list(:booking, 3, flight: flights[0])
        create_list(:booking, 3, flight: flights[1])
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

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]['total_revenue']).to eq(total_revenue)
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

        average_price_of_seats = total_revenue / total_booked_seats

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'][0]['average_price_of_seats']).to eq(average_price_of_seats)
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
  end
end
