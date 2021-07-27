RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse

  let(:invalid_params) do
    { flight_id: '', no_of_seats: '', seat_price: '', user_id: '' }
  end

  describe 'GET /bookings' do
    let!(:bookings) { create_list(:booking, 3) }

    context 'when using blueprinter with root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings'

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(bookings.count)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(bookings.count)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(bookings.count)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: api_headers(default_serializer: false, not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(bookings.count)
      end
    end
  end

  describe 'GET /bookings/:id' do
    let!(:booking) { create(:booking) }

    context 'when using blueprinter' do
      it 'returns a single booking' do
        get "/api/bookings/#{booking.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('booking' => { 'id' => anything,
                                                    'flight' => anything,
                                                    'no_of_seats' => anything,
                                                    'seat_price' => anything,
                                                    'user' => anything,
                                                    'created_at' => anything,
                                                    'updated_at' => anything })
      end
    end

    context 'when using jsonapi-serializer' do
      it 'successfully returns a list of bookings' do
        get "/api/bookings/#{booking.id}",
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('booking' => anything)
      end
    end
  end

  describe 'POST /bookings' do
    let!(:booking) { build(:booking).serializable_hash }

    context 'when params are valid' do
      it 'creates a booking' do
        post '/api/bookings',
             params: { booking: booking.compact }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include(booking.merge({ 'flight_id' => nil,
                                                                'flight' => anything,
                                                                'user_id' => nil,
                                                                'user' => anything }).compact)
      end

      it 'creates a booking in db' do
        post '/api/bookings',
             params: { booking: booking.compact }.to_json,
             headers: api_headers

        id = json_body['booking']['id']

        expect(Booking.where({ id: id }.merge(booking.compact))).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/bookings',
             params: { booking: invalid_params }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('user', 'flight', 'seat_price', 'no_of_seats')
      end

      it 'does not create a booking in db' do
        count = Booking.count

        post '/api/bookings',
             params: { booking: invalid_params }.to_json,
             headers: api_headers

        expect(Booking.count).to eq(count)
        expect(Booking.where(invalid_params)).not_to exist
      end
    end
  end

  describe 'PUT /bookings/:id' do
    let!(:booking) { create(:booking) }

    context 'when params are valid' do
      it 'updates a booking' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json, headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('seat_price' => 1000,
                                                'no_of_seats' => 4,
                                                'id' => booking.id)
      end

      it 'updates a booking in db' do
        put "/api/bookings/#{booking.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json, headers: api_headers

        expect(Booking.where(id: booking.id, seat_price: 1000, no_of_seats: 4)).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/bookings/#{booking.id}",
            params: { booking: invalid_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('user', 'flight', 'seat_price', 'no_of_seats')
      end

      it 'does not update a booking in db' do
        put "/api/bookings/#{booking.id}",
            params: { booking: invalid_params }.to_json,
            headers: api_headers

        expect(Booking.where({ id: booking.id }.merge(invalid_params))).not_to exist
      end
    end
  end

  describe 'DELETE /bookings/:id' do
    let!(:booking) { create(:booking) }

    it 'deletes a booking in db and returns 204 no content' do
      delete "/api/bookings/#{booking.id}"

      expect(response).to have_http_status(:no_content)
      expect(Booking.where(id: booking.id)).not_to exist
    end
  end
end
