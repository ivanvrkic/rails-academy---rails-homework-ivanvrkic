module Api
  class SessionController < ApplicationController
    skip_before_action :auth

    def create
      user = User.find_by(email: session_params[:email])
      if user&.authenticate(session_params[:password])
        render json: json_session(user), status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    def destroy
      user = User.find_by(token: request.headers['Authorization'])
      if user&.regenerate_token
        render json: { ok: 'logged out' }, status: :no_content
      else
        render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
      end
    end

    private

    def session_params
      params.require(:session).permit(:email,
                                      :password)
    end

    def json_session(session)
      { session: { token: session.token, user: UserSerializer.render_as_hash(session) } }
    end
  end
end
