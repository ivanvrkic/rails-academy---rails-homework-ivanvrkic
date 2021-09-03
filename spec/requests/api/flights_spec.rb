RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user) { create(:user) }
  let!(:user_admin) { create(:user, role: 'admin') }

  describe 'GET /api/flights' do
    context 'when flights exist in db' do
      let!(:flights) { create_list(:flight, 3) }

      before do
        create_list(:booking, 2, flight: flights[1])
        create_list(:booking, 1, flight: flights[2])
      end

      it 'successfully returns a list of flights when using blueprinter with root' do
        get '/api/flights',
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(flights.count)
      end

      it 'successfully returns a list of flights when using blueprinter without root' do
        get '/api/flights',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(flights.count)
      end

      it 'successfully returns a list of flights when using jsonapi-serializer with root' do
        get '/api/flights',
            headers: api_headers(default_serializer: false)
        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(flights.count)
      end

      it 'successfully returns a list of flights when using jsonapi-serializer without root' do
        get '/api/flights',
            headers: api_headers(default_serializer: false, not_root: true)
        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(flights.count)
      end

      it 'orders flights by departs_at, name and created_at ASC' do
        get '/api/flights',
            headers: api_headers

        sorted_ids = flights.reject { |flight| flight.departs_at <= DateTime.now }
                            .sort_by do |flight|
          [flight.departs_at,
           flight.name,
           flight.created_at]
        end

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].map(&by_id)).to eq(sorted_ids.map(&by_id))
      end

      it 'contains only active flights' do
        get '/api/flights',
            headers: api_headers

        active_flights_ids = flights.reject { |flight| flight.departs_at <= DateTime.now }
                                    .map(&by_id)

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].map(&by_id)).to eq(active_flights_ids)
      end

      it 'filters by name' do
        get '/api/flights',
            params: { name_cont: 'flight10997' },
            headers: api_headers

        name_filter_ids = flights.reject { |flight| flight.departs_at <= DateTime.now }
                                 .select { |flight| flight.name.downcase.include? 'flight10997' }
                                 .map(&by_id)

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].map(&by_id)).to eq(name_filter_ids)
      end

      it 'filters by departs_at' do
        get '/api/flights',
            params: { departs_at_eq: 1.day.from_now.to_date },
            headers: api_headers

        departs_at_filter_ids = flights.reject { |flight| flight.departs_at <= DateTime.now }
                                       .select do |flight|
                                         (flight.departs_at.to_date == 1.day.from_now.to_date)
                                       end

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].map(&by_id)).to eq(departs_at_filter_ids.map(&by_id))
      end

      it 'filters by number of available seats' do
        get '/api/flights',
            params: { no_of_available_seats_gteq: 7 },
            headers: api_headers

        seats_filter_ids = flights.reject { |f| f.departs_at <= DateTime.now }
                                  .select { |f| f.no_of_seats - f.bookings.sum(:no_of_seats) >= 7 }
                                  .map(&by_id)

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].map(&by_id)).to eq(seats_filter_ids)
      end

      it 'has number of booked seats for each flight' do
        get '/api/flights',
            headers: api_headers

        seats_ids = flights.reject { |f| f.departs_at <= DateTime.now }.map do |f|
          { 'id' => f.id, 'no_of_booked_seats' => f.bookings.sum(:no_of_seats) }
        end

        body_seats_ids = json_body['flights'].map do |f|
          { 'id' => f['id'], 'no_of_booked_seats' => f['no_of_booked_seats'] }
        end

        expect(response).to have_http_status(:ok)
        expect(body_seats_ids).to eq(seats_ids)
      end

      it 'has name of company for each flight' do
        get '/api/flights',
            headers: api_headers

        company_names_ids = flights.reject { |f| f.departs_at <= DateTime.now }.map do |f|
          { 'id' => f.id, 'company_name' => f.company.name }
        end

        body_company_names_ids = json_body['flights'].map do |f|
          { 'id' => f['id'], 'company_name' => f['company_name'] }
        end

        expect(response).to have_http_status(:ok)
        expect(body_company_names_ids).to eq(company_names_ids)
      end

      it 'has current price for each flight' do
        get '/api/flights',
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'][0]).to include('current_price' => anything)
      end
    end

    context 'when flights do not exist in db' do
      it 'returns an empty flight list' do
        get '/api/flights',
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(0)
      end
    end
  end

  describe 'GET /api/flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when flight exists' do
      it 'returns a single flight when using blueprinter' do
        get "/api/flights/#{flight.id}",
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('id' => anything,
                                               'arrives_at' => anything,
                                               'base_price' => anything,
                                               'company' => anything,
                                               'departs_at' => anything,
                                               'name' => anything,
                                               'no_of_seats' => anything)
      end

      it 'successfully returns a list of flights when using jsonapi-serializer' do
        get "/api/flights/#{flight.id}",
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('flight' => anything)
      end
    end

    context 'when flight does not exist' do
      it 'returns 404 not found' do
        get '/api/flights/1',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:not_found)
        expect(json_body['errors']).to include('not found')
      end
    end
  end

  describe 'POST /api/flights' do
    let!(:flight) { build(:flight) }
    let(:params) do
      { 'company_id' => nil,
        'company' => anything,
        'departs_at' => flight.departs_at.to_s,
        'arrives_at' => flight.arrives_at.to_s }
    end

    context 'when user is authenticated and authorized (admin) and params are valid' do
      it 'creates a flight' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include(flight.serializable_hash.merge(params).compact)
      end

      it 'creates a flight in db' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        id = json_body['flight']['id']

        expect(Flight.where({ id: id }.merge(flight.serializable_hash.compact))).to exist
      end

      it 'prevents overlapping of flights' do
        flight = create(:flight)
        overlapping_flight = build(:flight,
                                   departs_at: flight.departs_at + 1.hour,
                                   name: 'overlapping-flight',
                                   company: flight.company)

        post '/api/flights',
             params: { flight: overlapping_flight.serializable_hash.compact }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('departs_at', 'arrives_at')
      end
    end

    context 'when user is authenticated and authorized (admin) and params are invalid' do
      let(:invalid_params) do
        { name: '', company: '' }
      end

      it 'returns 400 Bad Request' do
        post '/api/flights',
             params: { flight: invalid_params }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('arrives_at',
                                               'base_price',
                                               'company',
                                               'departs_at',
                                               'name',
                                               'no_of_seats')
      end

      it 'does not create a flight in db' do
        count = Flight.count

        post '/api/flights',
             params: { flight: invalid_params }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(Flight.count).to eq(count)
        expect(Flight.where(invalid_params)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'PUT /api/flights/:id' do
    let!(:flights) { create_list(:flight, 2) }

    context 'when user is authenticated and authorized (admin) and params are valid' do
      it 'updates a flight' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('base_price' => 999,
                                               'no_of_seats' => 4,
                                               'id' => flights[0].id)
      end

      it 'updates a flight in db' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(Flight.where(id: flights[0].id, base_price: 999,
                            no_of_seats: 4)).to exist
      end

      it 'prevents overlapping of flights' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { departs_at: flights[1].departs_at + 1.hour,
                                arrives_at: flights[1].arrives_at + 1.hour,
                                company_id: flights[1].company_id } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('departs_at', 'arrives_at')
      end
    end

    context 'when user is authenticated and authorized (admin) and params are invalid' do
      let(:invalid_params) do
        { name: '', company: '' }
      end

      it 'returns 400 Bad Request' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { name: '', arrives_at: '',
                                base_price: '', company_id: '', no_of_seats: '' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('arrives_at', 'base_price', 'company',
                                               'departs_at', 'name', 'no_of_seats')
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { name: 'Newflight1',
                                base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        put "/api/flights/#{flights[0].id}",
            params: { flight: { name: 'Newflight1',
                                base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'DELETE /api/flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when user is authenticated and authorized (admin)' do
      it 'deletes a flight in db and returns 204 no content' do
        delete "/api/flights/#{flight.id}",
               headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:no_content)
        expect(Flight.where(id: flight.id)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        delete "/api/flights/#{flight.id}",
               headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        delete "/api/flights/#{flight.id}",
               headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end
end
