module Api
  class UsersController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_all_users : blueprinter_all_users
    end

    def show
      user = User.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_user(user)
                   else
                     UserSerializer.render(user,
                                           root: :user)
                   end
    end

    def create
      user = User.new(user_params)
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def update
      user = User.find(params[:id])
      if user&.update(user_params)
        render json: user, status: :ok
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    def destroy
      user = User.find(params[:id])
      if user&.destroy
        render json: user, status: :ok
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

    def jsonapi_all_users
      JsonapiSerializer::UserSerializer.new(User.all).public_send(json_root_method)
    end

    def jsonapi_user(user)
      JsonapiSerializer::UserSerializer.new(user).json_with_root
    end

    def blueprinter_all_users
      root? ? UserSerializer.render(User.all, root: :users) : UserSerializer.render(User.all)
    end
  end
end
