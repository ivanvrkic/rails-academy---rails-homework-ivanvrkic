RSpec.describe 'Flights API', type: :request do
  include TestHelpers::JsonResponse
  let(:arriving_date) { 12.hours.from_now }
  let(:departing_date) { 6.hours.from_now }
  let(:invalid_params) do
    { name: '', company: '' }
  end

  describe 'GET /flights' do
    let!(:flights) { create_list(:flight, 3) }

    context 'when using blueprinter with root' do
      it 'successfully returns a list of flights' do
        get '/api/flights'

        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(flights.count)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(flights.count)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: api_headers(default_serializer: false)
        expect(response).to have_http_status(:ok)
        expect(json_body['flights'].count).to eq(flights.count)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of flights' do
        get '/api/flights',
            headers: api_headers(default_serializer: false, not_root: true)
        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(flights.count)
      end
    end
  end

  describe 'GET /flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when using blueprinter' do
      it 'returns a single flight' do
        get "/api/flights/#{flight.id}"

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
        get "/api/flights/#{flight.id}",
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('flight' => anything)
      end
    end
  end

  describe 'POST /flights' do
    let!(:flight) { build(:flight) }
    let(:params) do
      { 'company_id' => nil,
        'company' => anything,
        'departs_at' => flight.departs_at.to_s,
        'arrives_at' => flight.arrives_at.to_s }
    end

    context 'when params are valid' do
      it 'creates a flight' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['flight']).to include(flight.serializable_hash.merge(params).compact)
      end

      it 'creates a flight in db' do
        post '/api/flights',
             params: { flight: flight.serializable_hash.compact }.to_json,
             headers: api_headers

        id = json_body['flight']['id']

        expect(Flight.where({ id: id }.merge(flight.serializable_hash.compact))).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/flights',
             params: { flight: invalid_params }.to_json,
             headers: api_headers

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
             headers: api_headers

        expect(Flight.count).to eq(count)
        expect(Flight.where(invalid_params)).not_to exist
      end
    end
  end

  describe 'PUT /flights/:id' do
    let!(:flight) { create(:flight) }

    context 'when params are valid' do
      it 'updates a flight' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: 'Newflight1',
                                base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['flight']).to include('name' => 'Newflight1',
                                               'base_price' => 999,
                                               'no_of_seats' => 4,
                                               'id' => flight.id)
      end

      it 'updates a flight in db' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: 'Newflight1',
                                base_price: 999,
                                no_of_seats: 4 } }.to_json,
            headers: api_headers

        expect(Flight.where(id: flight.id, name: 'Newflight1', base_price: 999,
                            no_of_seats: 4)).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/flights/#{flight.id}",
            params: { flight: { name: '', arrives_at: '',
                                base_price: '', company_id: '', no_of_seats: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('arrives_at', 'base_price', 'company',
                                               'departs_at', 'name', 'no_of_seats')
      end
    end
  end

  describe 'DELETE /flights/:id' do
    let!(:flight) { create(:flight) }

    it 'deletes a flight in db and returns 204 no content' do
      delete "/api/flights/#{flight.id}"

      expect(response).to have_http_status(:no_content)
      expect(Flight.where(id: flight.id)).not_to exist
    end
  end
end
