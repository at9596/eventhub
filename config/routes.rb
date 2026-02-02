Rails.application.routes.draw do
  post "/webhooks/stripe", to: "webhooks#stripe"
  namespace :api do
  namespace :v1 do
    resources :events, only: [ :create, :update, :destroy, :index ] do
      resources :bookings, only: [ :create ]
    end

    resources :bookings, only: [ :show ] do
      member do
        patch :cancel
      end
    end
  end
end
  post "/auth/login", to: "authentication#login"
  post "/auth/signup", to: "users#create"
end
