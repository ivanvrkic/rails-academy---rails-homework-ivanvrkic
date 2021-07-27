RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse

  let(:invalid_params) do
    { first_name: '', email: '' }
  end

  describe 'GET /users' do
    context 'when users exist in db' do
      let!(:users) { create_list(:user, 3) }

      it 'successfully returns a list of users when using blueprinter with root' do
        get '/api/users'

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(users.count)
      end

      it 'successfully returns a list of users when using blueprinter without root' do
        get '/api/users',
            headers: api_headers(not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(users.count)
      end

      it 'successfully returns a list of users when using jsonapi-serializer with root' do
        get '/api/users',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(users.count)
      end

      it 'successfully returns a list of users when using jsonapi-serializer without root' do
        get '/api/users',
            headers: api_headers(default_serializer: false, not_root: true)

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(users.count)
      end
    end

    context 'when users do not exist in db' do
      it 'returns an empty user list' do
        get '/api/users'

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(0)
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when user exists' do
      let!(:user) { create(:user) }

      it 'returns a single user when using blueprinter' do
        get "/api/users/#{user.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => anything,
                                             'id' => anything,
                                             'email' => anything,
                                             'last_name' => anything,
                                             'created_at' => anything,
                                             'updated_at' => anything)
      end

      it 'successfully returns a list of users when using jsonapi-serializer' do
        get "/api/users/#{user.id}",
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('user' => { 'first_name' => anything,
                                                 'id' => anything,
                                                 'email' => anything,
                                                 'last_name' => anything,
                                                 'created_at' => anything,
                                                 'updated_at' => anything })
      end
    end

    context 'when user does not exist' do
      it 'returns 404 not found' do
        get '/api/users/1',
            headers: api_headers(default_serializer: false)

        expect(response).to have_http_status(:not_found)
        expect(json_body['errors']).to include('not found')
      end
    end
  end

  describe 'POST /users' do
    let!(:user) { build(:user) }

    context 'when params are valid' do
      it 'creates a user' do
        post '/api/users',
             params: { user: user.serializable_hash.compact }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include(user.serializable_hash.compact)
      end

      it 'creates a user in db' do
        post '/api/users',
             params: { user: user.serializable_hash.compact }.to_json,
             headers: api_headers

        id = json_body['user']['id']

        expect(User.where({ id: id }.merge(user.serializable_hash.compact))).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/users',
             params: { user: invalid_params }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
      end

      it 'does not create a user in db' do
        count = User.count

        post '/api/users',
             params: { user: invalid_params }.to_json,
             headers: api_headers

        expect(User.count).to eq(count)
        expect(User.where(invalid_params)).not_to exist
      end
    end
  end

  describe 'PUT /users/:id' do
    let!(:user) { create(:user) }

    context 'when params are valid' do
      it 'updates a user' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'User',
                                             'email' => 'newuser@mail.com',
                                             'id' => user.id)
      end

      it 'updates a user in db' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers

        expect(User.where(first_name: 'User', email: 'newuser@mail.com')).to exist
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/users/#{user.id}",
            params: { user: invalid_params }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
      end

      it 'does not update a user in db' do
        put "/api/users/#{user.id}",
            params: { user: invalid_params }.to_json,
            headers: api_headers

        expect(User.where({ id: user.id }.merge(invalid_params))).not_to exist
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:user) { create(:user) }

    it 'deletes a user in db and returns 204 no content' do
      delete "/api/users/#{user.id}"

      expect(response).to have_http_status(:no_content)
      expect(User.where(id: user.id)).not_to exist
    end
  end
end
