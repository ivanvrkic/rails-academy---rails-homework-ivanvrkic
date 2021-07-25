RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:companies) { create_list(:company, 3) }

  describe 'GET /companies' do
    context 'when using blueprinter with root' do
      it 'successfully returns a list of companies' do
        get '/api/companies'

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(3)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: { HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }

        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer']['companies'].count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer',
                       HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer'].count).to eq(3)
      end
    end
  end

  describe 'GET /companies/:id' do
    context 'when using blueprinter' do
      it 'returns a single company' do
        get "/api/companies/#{companies.first.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => companies.first.name,
                                                'id' => companies.first.id)
      end
    end

    context 'when using jsonapi-serializer' do
      it 'successfully returns a list of companies' do
        get "/api/companies/#{companies.first.id}",
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }
        expect(response).to have_http_status(:ok)
        expect(json_body).to include('jsonapi-serializer' => { 'company' => anything })
      end
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      it 'creates a company' do
        count = Company.count
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers

        expect(Company.count).to eq(count + 1)
        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'Croatia Airlines')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/companies',
             params: { company: { name: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end

  describe 'PUT /companies/:id' do
    context 'when params are valid' do
      it 'updates a company' do
        put "/api/companies/#{companies.first.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers

        expect(Company.find(companies.first.id).name).to eq('Croatia Airlines')
        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => 'Croatia Airlines',
                                                'id' => companies.first.id)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/companies/#{companies.first.id}",
            params: { company: { name: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end
    end
  end
end
