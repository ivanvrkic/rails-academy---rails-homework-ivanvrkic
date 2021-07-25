RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let!(:flights) { create_list(:flight, 3) }
  let(:arriving_date) { 12.hours.from_now }
  let(:departing_date) { 6.hours.from_now }

  describe 'GET /flights' do
    context 'when using blueprinter with root' do
      it 'successfully returns a list of flights' do
        get '/api/flights'

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(3)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: { HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }
        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer']['flights'].count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer',
                       HTTP_X_API_SERIALIZER_ROOT: '0' }
        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer'].count).to eq(3)
      end
    end
  end

  describe 'GET /flights/:id' do
    context 'when using blueprinter' do
      it 'returns a single flight' do
        get "/api/flights/#{flights.first.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('id' => anything,
                                               'arrives_at' => anything,
                                               'base_price' => anything,
                                               'company' => anything,
                                               'departs_at' => anything,
                                               'name' => anything,
                                               'no_of_seats' => anything)
      end
    end

    context 'when using jsonapi-serializer' do
      it 'successfully returns a list of flights' do
        get "/api/flights/#{flights.first.id}",
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }
        expect(response).to have_http_status(:ok)
        expect(json_body).to include('jsonapi-serializer' => { 'flight' => anything })
      end
    end
  end

  describe 'POST /flights' do
    context 'when params are valid' do
      it 'creates a flight' do
        count = Flight.count
        post '/api/flights',
             params: { flight: flight_hash }.to_json,
             headers: api_headers

        expect(Flight.count).to eq(count + 1)
        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include(flight_hash_response.stringify_keys)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/flights',
             params: { flight: { name: '', company: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('arrives_at', 'base_price', 'company',
                                               'departs_at', 'name', 'no_of_seats')
      end
    end
  end

  describe 'PUT /flights/:id' do
    context 'when params are valid' do
      it 'updates a flight' do
        put "/api/flights/#{flights.first.id}",
            params: { flight: { name: 'Newflight1', base_price: 999,
                                no_of_seats: 4 } }.to_json, headers: api_headers

        flight = Flight.find(flights.first.id)

        expect(flight.name).to eq('Newflight1')
        expect(flight.base_price).to eq(999)
        expect(flight.no_of_seats).to eq(4)
        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name' => 'Newflight1', 'base_price' => 999,
                                               'no_of_seats' => 4, 'id' => flights.first.id)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/flights/#{flights.first.id}",
            params: { flight: { name: '', arrives_at: '',
                                base_price: '', company_id: '', no_of_seats: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('arrives_at', 'base_price', 'company',
                                               'departs_at', 'name', 'no_of_seats')
      end
    end
  end
end
