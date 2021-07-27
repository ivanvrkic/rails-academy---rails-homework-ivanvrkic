RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

  describe 'GET /companies' do
    context 'when companies exist in db' do
      let!(:companies) { create_list(:company, 3) }

      it 'successfully returns a list of companies when using blueprinter with root' do
        get '/api/companies'

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(companies.count)
      end

      it 'successfully returns a list of companies when using blueprinter without root' do
        get '/api/companies',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(companies.count)
      end

      it 'successfully returns a list of companies when using jsonapi-serializer with root' do
        get '/api/companies',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(companies.count)
      end

      it 'successfully returns a list of companies when using jsonapi-serializer without root' do
        get '/api/companies',
            headers: api_headers(default_serializer: false, not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(companies.count)
      end
    end

    context 'when companies do not exist in db' do
      it 'returns an empty company list' do
        get '/api/companies'

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(0)
      end
    end
  end

  describe 'GET /companies/:id' do
    context 'when company exists' do
      let!(:company) { create(:company) }

      it 'returns a single company when using blueprinter' do
        get "/api/companies/#{company.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => company.name,
                                                'id' => company.id)
      end

      it 'successfully returns a single when using jsonapi-serializer' do
        get "/api/companies/#{company.id}",
            headers: api_headers(default_serializer: false)
        expect(response).to have_http_status(:ok)
        expect(json_body).to include('company' => anything)
      end
    end

    context 'when company does not exist' do
      it 'returns 404 not found' do
        get '/api/companies/1',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:not_found)
        expect(json_body['errors']).to include('not found')
      end
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      it 'creates a company' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'Croatia Airlines')
      end

      it 'creates a company in db' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers

        id = json_body['company']['id']

        expect(Company.where(id: id, name: 'Croatia Airlines')).to exist
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'returns 400 Bad Request' do
        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end

      it 'does not create a company in db' do
        count = Company.count

        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: api_headers

        expect(Company.count).to eq(count)
        expect(Company.where(invalid_params)).not_to exist
      end
    end
  end

  describe 'PUT /companies/:id' do
    let!(:company) { create(:company) }

    context 'when params are valid' do
      it 'updates a company' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => 'Croatia Airlines',
                                                'id' => company.id)
      end

      it 'updates a company in db' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers

        expect(Company.where(id: company.id, name: 'Croatia Airlines')).to exist
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'returns 400 Bad Request' do
        put "/api/companies/#{company.id}",
            params: { company: invalid_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end

      it 'does not update a company in db' do
        put "/api/companies/#{company.id}",
            params: { company: invalid_params }.to_json,
            headers: api_headers

        expect(Company.where({ id: company.id }.merge(invalid_params))).not_to exist
      end
    end
  end

  describe 'DELETE /companies/:id' do
    let!(:company) { create(:company) }

    it 'deletes a company in db and returns 204 no content' do
      delete "/api/companies/#{company.id}"

      expect(response).to have_http_status(:no_content)
      expect(Company.where(id: company.id)).not_to exist
    end
  end
end
