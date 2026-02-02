class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [ :login ]
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"), user: @user }, status: :ok
    else
      render json: { errors: "Invalid email or password" }, status: :unauthorized
    end
  end
end
