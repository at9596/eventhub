class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [ :login ]
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)

      # Setting the HttpOnly Cookie
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,    # Prevents JS access
        secure: Rails.env.production?, # Only sends over HTTPS in production
        same_site: :lax,   # Protects against basic CSRF
        expires: 24.hours.from_now
      }
      render json: { token: token, user: @user }, status: :ok
    else
      render json: { errors: "Invalid email or password" }, status: :unauthorized
    end
  end
end
