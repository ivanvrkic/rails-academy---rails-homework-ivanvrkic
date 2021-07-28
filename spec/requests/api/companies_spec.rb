RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user) { create(:user) }
  let!(:user_admin) { create(:user, role: 'admin') }

  describe 'GET /api/companies' do
    context 'when companies exist in db' do
      let!(:companies) { create_list(:company, 3) }

      it 'successfully returns a list of companies when using blueprinter with root' do
        get '/api/companies',
            headers: api_headers

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
        get '/api/companies',
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['companies'].count).to eq(0)
      end
    end
  end

  describe 'GET /api/companies/:id' do
    context 'when company exists' do
      let!(:company) { create(:company) }

      it 'returns a single company when using blueprinter' do
        get "/api/companies/#{company.id}",
            headers: api_headers

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

  describe 'POST /api/companies' do
    context 'when user is authenticated and authorized (admin)' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'creates a company with valid params' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:created)
        expect(json_body['company']).to include('name' => 'Croatia Airlines')
      end

      it 'creates a company in db with valid params' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        id = json_body['company']['id']

        expect(Company.where(id: id, name: 'Croatia Airlines')).to exist
      end

      it 'returns 400 Bad Request with invalid params' do
        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end

      it 'does not create a company in db with invalid params' do
        count = Company.count

        post '/api/companies',
             params: { company: invalid_params }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(Company.count).to eq(count)
        expect(Company.where(invalid_params)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('forbidden' => ['not authorized'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        post '/api/companies',
             params: { company: { name: 'Croatia Airlines' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'PUT /api/companies/:id' do
    let!(:company) { create(:company) }

    context 'when user is authenticated and authorized (admin)' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'updates a company with valid params' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['company']).to include('name' => 'Croatia Airlines',
                                                'id' => company.id)
      end

      it 'updates a company in db with valid params' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(Company.where(id: company.id, name: 'Croatia Airlines')).to exist
      end

      it 'returns 400 Bad Request with invalid params' do
        put "/api/companies/#{company.id}",
            params: { company: invalid_params }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
      end

      it 'does not update a company in db with invalid params' do
        put "/api/companies/#{company.id}",
            params: { company: invalid_params }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(Company.where({ id: company.id }.merge(invalid_params))).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('forbidden' => ['not authorized'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        put "/api/companies/#{company.id}",
            params: { company: { name: 'Croatia Airlines' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'DELETE /api/companies/:id' do
    let!(:company) { create(:company) }

    context 'when user is authenticated and authorized (admin)' do
      it 'deletes a company in db and returns 204 no content' do
        delete "/api/companies/#{company.id}",
               headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:no_content)
        expect(Company.where(id: company.id)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        delete "/api/companies/#{company.id}",
               headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('forbidden' => ['not authorized'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        delete "/api/companies/#{company.id}",
               headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end
end
