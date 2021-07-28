RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse
  let!(:user_admin) { create(:user, role: 'admin') }
  let!(:user_regular) { create(:user) }

  describe 'GET /api/users' do
    context 'when user is authenticated and authorized and users exist in db' do
      let!(:users) { create_list(:user, 3) }

      it 'successfully returns a list of users when using blueprinter with root' do
        get '/api/users',
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(users.count + 2)
      end

      it 'successfully returns a list of users when using blueprinter without root' do
        get '/api/users',
            headers: api_headers(not_root: true).merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(users.count + 2)
      end

      it 'successfully returns a list of users when using jsonapi-serializer with root' do
        get '/api/users',
            headers: api_headers(default_serializer: false).merge(
              { Authorization: user_admin.token }
            )

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(users.count + 2)
      end

      it 'successfully returns a list of users when using jsonapi-serializer without root' do
        get '/api/users',
            headers: api_headers(default_serializer: false,
                                 not_root: true).merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(users.count + 2)
      end
    end

    context 'when user is authenticated and not authorized' do
      let!(:user) { create(:user) }

      it 'successfully returns a list of users when using blueprinter with root' do
        get '/api/users',
            headers: api_headers.merge({ Authorization: user.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        get '/api/users',
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'GET /api/users/:id' do
    let!(:user) { create(:user) }
    let(:user_schema) do
      { 'first_name' => anything,
        'id' => anything,
        'email' => anything,
        'last_name' => anything,
        'created_at' => anything,
        'updated_at' => anything,
        'role' => anything }
    end

    context 'when user is authenticated and authorized (admin) and user id exists' do
      it 'returns a single user when using blueprinter' do
        get "/api/users/#{user.id}",
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include(user_schema)
      end

      it 'successfully returns a list of users when using jsonapi-serializer' do
        get "/api/users/#{user.id}",
            headers: api_headers(default_serializer: false).merge(
              { Authorization: user_admin.token }
            )

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include(user_schema)
      end
    end

    context 'when user is authenticated and authorized (admin) and user id not exist' do
      it 'returns 404 not found' do
        get '/api/users/1',
            headers: api_headers(default_serializer: false).merge(
              { Authorization: user_admin.token }
            )

        expect(response).to have_http_status(:not_found)
        expect(json_body['errors']).to include('not found')
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        get "/api/users/#{user.id}",
            headers: api_headers.merge({ Authorization: user_regular.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        get "/api/users/#{user.id}",
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'POST /api/users' do
    context 'when params are valid' do
      it 'creates a user' do
        post '/api/users',
             params: { user: { first_name: 'User',
                               email: 'em@il.com',
                               password: 'password123',
                               password_confirmation: 'password123' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'User', 'email' => 'em@il.com')
      end

      it 'creates a user with admin role when admin' do
        post '/api/users',
             params: { user: { first_name: 'User',
                               email: 'em@il.com',
                               password: 'password123',
                               password_confirmation: 'password123',
                               role: 'admin' } }.to_json,
             headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'User', 'email' => 'em@il.com')
      end

      it 'does not create a user with admin role when not admin' do
        post '/api/users',
             params: { user: { first_name: 'User',
                               email: 'em@il.com',
                               password: 'password123',
                               password_confirmation: 'password123',
                               role: 'admin' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end

      it 'creates a user in db' do
        post '/api/users',
             params: { user: { first_name: 'User',
                               email: 'em@il.com',
                               password: 'password123',
                               password_confirmation: 'password123' } }.to_json,
             headers: api_headers

        id = json_body['user']['id']

        expect(User.where({ id: id }.merge({ 'first_name' => 'User',
                                             'email' => 'em@il.com' }))).to exist
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { first_name: '', email: '' }
      end

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

  describe 'PUT /api/users/:id' do
    let!(:user) { create(:user) }

    context 'when user is authenticated and authorized (admin)' do
      let(:invalid_params) do
        { first_name: '', email: '' }
      end

      it 'updates a user with when params are valid' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'User',
                                             'email' => 'newuser@mail.com',
                                             'id' => user.id)
      end

      it 'updates a user role when params are valid' do
        put "/api/users/#{user.id}",
            params: { user: { role: 'admin' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('role' => 'admin',
                                             'id' => user.id)
      end

      it 'updates a user in db when params are valid' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(User.where(first_name: 'User', email: 'newuser@mail.com')).to exist
      end

      it 'returns 400 Bad Request when params are invalid' do
        put "/api/users/#{user.id}",
            params: { user: invalid_params }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
      end

      it 'does not update a user in db when params are invalid' do
        put "/api/users/#{user.id}",
            params: { user: invalid_params }.to_json,
            headers: api_headers.merge({ Authorization: user_admin.token })

        expect(User.where({ id: user.id }.merge(invalid_params))).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers.merge({ Authorization: user_regular.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end

      it 'does not update role and returns 403 Forbidden status' do
        put "/api/users/#{user.id}",
            params: { user: { role: 'admin' } }.to_json,
            headers: api_headers.merge({ Authorization: user_regular.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        put "/api/users/#{user.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    let!(:user) { create(:user) }

    context 'when user is authenticated and authorized (admin)' do
      it 'deletes a user in db and returns 204 no content' do
        delete "/api/users/#{user.id}",
               headers: api_headers.merge({ Authorization: user_admin.token })

        expect(response).to have_http_status(:no_content)
        expect(User.where(id: user.id)).not_to exist
      end
    end

    context 'when user is authenticated and not authorized' do
      it 'returns 403 Forbidden status' do
        delete "/api/users/#{user.id}",
               headers: api_headers.merge({ Authorization: user_regular.token })

        expect(response).to have_http_status(:forbidden)
        expect(json_body['errors']).to include('resource' => ['is forbidden'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 Unauthorized status' do
        delete "/api/users/#{user.id}",
               headers: api_headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_body['errors']).to include('token' => ['is invalid'])
      end
    end
  end
end
