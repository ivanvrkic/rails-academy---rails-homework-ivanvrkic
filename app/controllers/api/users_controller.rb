module Api
  class UsersController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_user(User.all) : blueprinter_all_users
    end

    def show
      user = User.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_user(user)
                   else
                     default_json_user(user)
                   end
    end

    def create
      user = User.new(user_params)
      if user.save
        render json: default_json_user(user), status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: default_json_user(user), status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])
      if user.destroy
        render json: user, status: :no_content
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    private

    def user_params
      params.require(:user).permit(:id,
                                   :email,
                                   :first_name,
                                   :last_name)
    end

    def default_json_user(user)
      UserSerializer.render(user, root: :user, view: :normal)
    end

    def jsonapi_user(user)
      JsonapiSerializer::UserSerializer.new(user).public_send(json_root_method)
    end

    def blueprinter_all_users
      if root?
        UserSerializer.render(User.all, root: :users, view: :normal)
      else
        UserSerializer.render(User.all, view: :normal)
      end
    end
  end
end
