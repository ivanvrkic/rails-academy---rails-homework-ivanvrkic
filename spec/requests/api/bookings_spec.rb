RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user) { create(:user) }
  let(:auth_header) { { Authorization: user.token } }

  describe 'GET /api/bookings' do
    context 'when user is authenticated and bookings exist in db' do
      let!(:bookings) { create_list(:booking, 3, user: user) }

      it 'successfully returns a list of bookings when using blueprinter with root' do
        get '/api/bookings',
            headers: api_headers.merge(auth_header)
        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(bookings.count)
      end

      it 'successfully returns a list of bookings when using blueprinter without root' do
        get '/api/bookings',
            headers: api_headers(not_root: true).merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(bookings.count)
      end

      it 'successfully returns a list of bookings when using jsonapi-serializer with root' do
        get '/api/bookings',
            headers: api_headers(default_serializer: false).merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(bookings.count)
      end

      it 'successfully returns a list of bookings when using jsonapi-serializer without root' do
        get '/api/bookings',
            headers: api_headers(default_serializer: false, not_root: true).merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(bookings.count)
      end
    end

    context 'when user is authenticated and bookings do not exist in db' do
      it 'returns an empty booking list' do
        get '/api/bookings',
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(0)
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        get '/api/bookings',
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'GET /api/bookings/:id' do
    context 'when user is authenticated and authorized (admin) and booking exists' do
      let!(:booking) { create(:booking, user: user) }

      it 'returns a single booking when using blueprinter' do
        get "/api/bookings/#{booking.id}",
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('booking' => { 'id' => anything,
                                                    'flight' => anything,
                                                    'no_of_seats' => anything,
                                                    'seat_price' => anything,
                                                    'user' => anything,
                                                    'created_at' => anything,
                                                    'updated_at' => anything })
      end

      it 'successfully returns a single booking when using jsonapi-serializer' do
        get "/api/bookings/#{booking.id}",
            headers: api_headers(default_serializer: false).merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('booking' => anything)
      end
    end

    context 'when user is authenticated and authorized (admin) and booking does not exist' do
      it 'returns 404 not found' do
        get '/api/bookings/1',
            headers: api_headers(default_serializer: false).merge(auth_header)

        expect(response).to have_http_status(:not_found)
        expect(json_body['errors']).to include('not found')
      end
    end

    context 'when user is authenticated and not authorized' do
      let!(:booking) { create(:booking) }

      it 'returns 403 Forbidden status' do
        get "/api/bookings/#{booking.id}",
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      let!(:booking) { create(:booking, user: user) }

      it 'returns 401 Unauthorized status' do
        get "/api/bookings/#{booking.id}",
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'POST /api/bookings' do
    let!(:booking) { build(:booking, user: user).serializable_hash }

    context 'when user is authenticated and authorized (admin) and params are valid' do
      it 'creates a booking' do
        post '/api/bookings',
             params: { booking: booking.compact }.to_json,
             headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include(booking.merge({ 'flight_id' => nil,
                                                                'flight' => anything,
                                                                'user_id' => nil,
                                                                'user' => anything }).compact)
      end

      it 'creates a booking in db' do
        post '/api/bookings',
             params: { booking: booking.compact }.to_json,
             headers: api_headers.merge(auth_header)

        id = json_body['booking']['id']

        expect(Booking.where({ id: id }.merge(booking.compact))).to exist
      end
    end

    context 'when user is authenticated and authorized (admin) and params are invalid' do
      let(:invalid_params) do
        { flight_id: '', no_of_seats: '', seat_price: '' }
      end

      it 'returns 400 Bad Request' do
        post '/api/bookings',
             params: { booking: invalid_params }.to_json,
             headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('flight', 'seat_price', 'no_of_seats')
      end

      it 'does not create a booking in db' do
        count = Booking.count

        post '/api/bookings',
             params: { booking: invalid_params }.to_json,
             headers: api_headers.merge(auth_header)

        expect(Booking.count).to eq(count)
        expect(Booking.where(invalid_params)).not_to exist
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        post '/api/bookings',
             params: { booking: booking.compact }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'PUT /api/bookings/:id' do
    let!(:booking) { create(:booking, user: user) }
    let!(:booking2) { create(:booking) }

    context 'when user is authenticated and authorized (admin)' do
      let(:invalid_params) do
        { flight_id: '', no_of_seats: '', seat_price: '' }
      end

      it 'updates a booking with valid params' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json,
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('seat_price' => 1000,
                                                'no_of_seats' => 4,
                                                'id' => booking.id)
      end

      it 'updates a booking in db with valid params' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json,
            headers: api_headers.merge(auth_header)

        expect(Booking.where(id: booking.id, seat_price: 1000, no_of_seats: 4)).to exist
      end

      it 'returns 400 Bad Request with invalid params' do
        put "/api/bookings/#{booking.id}",
            params: { booking: invalid_params }.to_json,
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('flight', 'seat_price', 'no_of_seats')
      end

      it 'does not update a booking in db with invalid params' do
        put "/api/bookings/#{booking.id}",
            params: { booking: invalid_params }.to_json,
            headers: api_headers.merge(auth_header)

        expect(Booking.where({ id: booking.id }.merge(invalid_params))).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        put "/api/bookings/#{booking2.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json,
            headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'DELETE /api/bookings/:id' do
    let!(:booking) { create(:booking, user: user) }
    let!(:booking2) { create(:booking) }

    context 'when user is authenticated and authorized (admin)' do
      it 'deletes a booking in db and returns 204 no content' do
        delete "/api/bookings/#{booking.id}",
               headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:no_content)
        expect(Booking.where(id: booking.id)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        delete "/api/bookings/#{booking2.id}",
               headers: api_headers.merge(auth_header)

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        delete "/api/bookings/#{booking.id}",
               headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end
end
