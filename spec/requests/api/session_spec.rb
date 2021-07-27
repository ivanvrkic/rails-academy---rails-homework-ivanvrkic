RSpec.describe 'Session API', type: :request do
  include TestHelpers::JsonResponse
  let(:user) { create(:user) }

  describe 'POST /session' do
    it 'creates a session when login params are valid' do
      binding.pry
      post '/api/session',
            params: { session: {email: user.email, password: 'password123'} }.to_json,
            headers: api_headers

      expect(response).to have_http_status(:created)
      expect(json_body['session']).to include('user' => anything, 'token' => anything)
    end

    it 'returns an error when login params are invalid' do
      post '/api/session',
            params: { session: {email: user.email, password: 'wrongpassword' }}.to_json,
            headers: api_headers

      expect(response).to have_http_status(:bad_request)
      expect(json_body['errors']).to include('credentials' => ['are invalid'])
    end
  end

  describe 'DELETE api/session/' do
    it 'deletes a session in db and returns 204 no content' do
      user_token = user.token

      delete "/api/session/",
             headers: api_headers.merge({'Authorization' => user_token})

      expect(response).to have_http_status(:no_content)
      expect(User.where(token: user_token)).not_to exist
    end
  end
end
