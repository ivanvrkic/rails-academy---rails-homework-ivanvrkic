Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [:index, :show, :create, :update, :destroy]
    resources :bookings, only: [:index, :show, :create, :update, :destroy]
    resources :companies, only: [:index, :show, :create, :update, :destroy]
    resources :flights, only: [:index, :show, :create, :update, :destroy]
  end
end
