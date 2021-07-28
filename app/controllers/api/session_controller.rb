module Api
  class SessionController < ApplicationController
    skip_before_action :auth

    def create
      user = User.find_by(email: session_params[:email])
      session = user&.authenticate(session_params[:password])
      if session.is_a? User
        render json: json_session(session), status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    def destroy
      user = User.find_by(token: request.headers['Authorization'])
      if user&.regenerate_token
        render json: { ok: 'logged out' }, status: :no_content
      else
        render json: { errors: { token: ['is invalid'] } }, status: :bad_request
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
