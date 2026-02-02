class ApplicationController < ActionController::API
  before_action :authorize_request
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  attr_reader :current_user

  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end


  private
  def user_not_authorized
    render json: { errors: "You are not authorized to perform this action." }, status: :forbidden
  end
end
