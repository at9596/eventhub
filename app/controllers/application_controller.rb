class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :authorize_request
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  attr_reader :current_user

  def authorize_request
    # Access the signed cookie instead of the header
    token = cookies.signed[:jwt]

    begin
      if token
        # Decode the token (Ensure your JsonWebToken service is ready)
        @decoded = JsonWebToken.decode(token)
        @current_user = User.find(@decoded[:user_id])
      else
        render json: { errors: "Missing token" }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end


  private
  def user_not_authorized
    render json: { errors: "You are not authorized to perform this action." }, status: :forbidden
  end
end
