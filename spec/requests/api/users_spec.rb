RSpec.describe 'Users API', type: :request do
  include TestHelpers::JsonResponse
  let!(:users) { create_list(:user, 3) }

  describe 'GET /users' do
    context 'when using blueprinter with root' do
      it 'successfully returns a list of users' do
        get '/api/users'

        expect(response).to have_http_status(:ok)
        expect(json_body['users'].count).to eq(3)
      end
    end

    context 'when using blueprinter without root' do
      it 'successfully returns a list of users' do
        get '/api/users',
            headers: { HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body.count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer with root' do
      it 'successfully returns a list of users' do
        get '/api/users',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }

        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer']['users'].count).to eq(3)
      end
    end

    context 'when using jsonapi-serializer without root' do
      it 'successfully returns a list of users' do
        get '/api/users',
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer',
                       HTTP_X_API_SERIALIZER_ROOT: '0' }

        expect(response).to have_http_status(:ok)
        expect(json_body['jsonapi-serializer'].count).to eq(3)
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when using blueprinter' do
      it 'returns a single user' do
        get "/api/users/#{users.first.id}"

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('user' => { 'first_name' => anything,
                                                 'id' => anything,
                                                 'email' => anything,
                                                 'last_name' => anything,
                                                 'created_at' => anything,
                                                 'updated_at' => anything })
      end
    end

    context 'when using jsonapi-serializer' do
      it 'successfully returns a list of users' do
        get "/api/users/#{users.first.id}",
            headers: { HTTP_X_API_SERIALIZER: 'jsonapi-serializer' }

        expect(response).to have_http_status(:ok)
        expect(json_body).to include('jsonapi-serializer' => { 'user' => { 'first_name' => anything,
                                                                           'id' => anything,
                                                                           'email' => anything,
                                                                           'last_name' => anything,
                                                                           'created_at' => anything,
                                                                           'updated_at' => anything }})
      end
    end
  end

  describe 'POST /users' do
    context 'when params are valid' do
      it 'creates a user' do
        count = User.count
        post '/api/users',
             params: { user: { email: 'newuser@mail.com',
                               first_name: 'User',
                               last_name: 'User' } }.to_json,
             headers: api_headers

        expect(User.count).to eq(count + 1)
        expect(response).to have_http_status(:created)
        expect(json_body['user']).to include('first_name' => 'User', 'last_name' => 'User',
                                     'email' => 'newuser@mail.com')
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        post '/api/users',
             params: { user: { first_name: '', email: '' } }.to_json,
             headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
      end
    end
  end

  describe 'PUT /users/:id' do
    context 'when params are valid' do
      it 'updates a user' do
        put "/api/users/#{users.first.id}",
            params: { user: { email: 'newuser@mail.com', first_name: 'User',
                              last_name: 'User' } }.to_json, headers: api_headers

        user = User.find(users.first.id)

        expect(user.first_name).to eq('User')
        expect(user.last_name).to eq('User')
        expect(user.email).to eq('newuser@mail.com')
        expect(response).to have_http_status(:ok)
        expect(json_body['user']).to include('first_name' => 'User', 'last_name' => 'User',
                                     'email' => 'newuser@mail.com', 'id' => users.first.id)
      end
    end

    context 'when params are invalid' do
      it 'returns 400 Bad Request' do
        put "/api/users/#{users.first.id}",
            params: { user: { email: '', first_name: '' } }.to_json,
            headers: api_headers

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('first_name', 'email')
      end
    end
  end
end
