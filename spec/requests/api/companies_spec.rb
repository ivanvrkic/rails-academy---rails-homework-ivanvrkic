RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse

  let(:invalid_params) do
    { name: '' }
  end

  describe 'GET /companies' do
    let!(:companies) { create_list(:company, 3) }

    context 'when using blueprinter with root' do
      it 'successfully returns a list of companies' do
        get '/api/companies'

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(companies.count)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(companies.count)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(companies.count)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of companies' do
        get '/api/companies',
            headers: api_headers(default_serializer: false, not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(companies.count)
      end
    end
  end

  describe 'GET /companies/:id' do
    let!(:company) { create(:company) }

    context 'when using blueprinter' do
      it 'returns a single company' do
        get "/api/companies/#{company.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => company.name,
                                                'id' => company.id)
      end
    end

    context 'when using jsonapi-serializer' do
      it 'successfully returns a list of companies' do
        get "/api/companies/#{company.id}",
            headers: api_headers(default_serializer: false)
        expect(response).to have_http_status(:ok)
        expect(json_body).to include('company' => anything)
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
