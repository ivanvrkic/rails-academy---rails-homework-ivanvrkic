module Api
  class UsersController < ApplicationController
    skip_before_action :auth, only: [:create]

    def index
      users = User.all
      authorize users
      render json: jsonapi_serializer? ? jsonapi_user(users) : default_json_user(users)
    end

    def show
      user = User.find(params[:id])
      authorize user
      render json: if jsonapi_serializer?
                     jsonapi_user(user)
                   else
                     default_json_user(user)
                   end
    end

    def create
      user = User.new(merged_user_params)
      if user.save
        render json: default_json_user(user), status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def update
      user = User.find(params[:id])
      user.assign_attributes(user_params)
      authorize user
      if user.save
        render json: default_json_user(user), status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])
      authorize user
      if user.destroy
        render json: user, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    private

    def user_params
      params.require(:user).permit(:email,
                                   :first_name,
                                   :last_name,
                                   :password,
                                   :password_confirmation,
                                   :role)
    end

    def merged_user_params
      current_user&.admin? ? user_params : user_params.merge(role: nil)
    end

    def default_json_user(user)
      if root?
        root_name = user.is_a?(User) ? :user : :users
        UserSerializer.render(user, root: root_name, view: :normal)
      else
        UserSerializer.render(user, view: :normal)
      end
    end

    def jsonapi_user(user)
      JsonapiSerializer::UserSerializer.new(user).public_send(json_root_method)
    end

    def blueprinter_all_users; end
  end
end
