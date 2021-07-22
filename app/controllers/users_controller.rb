class UsersController < ApplicationController
  def index
    render json: UserSerializer.render(User.all)
  end

  def show
    user = User.find(params[:id])
    render json: UserSerializer.render(user)
  end
end
