Rails.application.routes.draw do
  post "/auth/login", to: "authentication#login"
  post "/auth/signup", to: "users#create"
end
