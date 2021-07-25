RSpec.describe 'Bookings API', type: :request do
  include TestHelpers::JsonResponse
  let!(:bookings) { create_list(:booking, 3) }
  let(:arriving_date) { 12.hours.from_now }
  let(:departing_date) { 6.hours.from_now }

  describe 'GET /bookings' do
    context 'when using blueprinter with root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings'

        expect(response).to have_http_status(:ok)
        expect(json_body['bookings'].count).to eq(3)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: { HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }
        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer']['bookings'].count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of bookings' do
        get '/api/bookings',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer',
                       HTTP_X_API_SERIALIZER_ROOT: '0' }
        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer'].count).to eq(3)
      end
    end
  end

  describe 'GET /bookings/:id' do
    context 'when using blueprinter' do
      it 'returns a single booking' do
        get "/api/bookings/#{bookings.first.id}"

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
        get "/api/bookings/#{bookings.first.id}",
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }
        expect(response).to have_http_status(:ok)
        expect(json_body).to include('jsonapi-serializer' => { 'booking' => anything })
      end
    end
  end

  describe 'POST /bookings' do
    context 'when params are valid' do
      it 'creates a booking' do
        count = Booking.count
        post '/api/bookings',
             params: { booking: booking_hash }.to_json,
             headers: api_headers

        expect(Booking.count).to eq(count + 1)
        expect(response).to have_http_status(:created)
        expect(json_body['booking']).to include(booking_hash_response.stringify_keys)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/bookings',
             params: { booking: { flight_id: '', no_of_seats: '', seat_price: '',
                                  user_id: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('user', 'flight', 'seat_price', 'no_of_seats')
      end
    end
  end

  describe 'PUT /bookings/:id' do
    context 'when params are valid' do
      it 'updates a booking' do
        put "/api/bookings/#{bookings.first.id}",
            params: { booking: { seat_price: 1000,
                                 no_of_seats: 4 } }.to_json, headers: api_headers

        booking = Booking.find(bookings.first.id)

        expect(booking.seat_price).to eq(1000)
        expect(booking.no_of_seats).to eq(4)
        expect(response).to have_http_status(:ok)
        expect(json_body['booking']).to include('seat_price' => 1000,
                                     'no_of_seats' => 4, 'id' => bookings.first.id)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/bookings/#{bookings.first.id}",
            params: { booking: { flight_id: '', no_of_seats: '', seat_price: '',
                                 user_id: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('user', 'flight', 'seat_price', 'no_of_seats')
      end
    end
  end
end
