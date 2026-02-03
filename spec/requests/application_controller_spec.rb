require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # We create a temporary controller to test the before_action and methods
  controller do
    def index
      render json: { message: "success" }, status: :ok
    end

    def check_pundit
      raise Pundit::NotAuthorizedError
    end
  end

  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe "authorize_request" do
    context "when a valid token is provided in a signed cookie" do
      before do
        # In controller specs, we can set the signed cookie directly
        request.cookies[:jwt] = ActionDispatch::Cookies::CookieJar.build(request, {}).tap { |dist|
          dist.signed[:jwt] = token
        }[:jwt]
      end

      it "sets the current_user and allows the request" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(controller.current_user).to eq(user)
      end
    end

    context "when an invalid token is provided" do
      before do
        # Setting a cookie that isn't signed correctly or has invalid data
        request.cookies[:jwt] = "invalid_signed_token_string"
      end

      it "returns an unauthorized status" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end

    context "when no token is provided" do
      it "returns an unauthorized status" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["errors"]).to eq("Missing token")
      end
    end
  end

  describe "Pundit Authorization" do
    before do
      # Provide a valid signed cookie to pass the authorize_request filter
      request.cookies[:jwt] = ActionDispatch::Cookies::CookieJar.build(request, {}).tap { |dist|
        dist.signed[:jwt] = token
      }[:jwt]
    end

    it "rescues from Pundit::NotAuthorizedError" do
      routes.draw { get "check_pundit" => "anonymous#check_pundit" }
      get :check_pundit

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["errors"]).to eq("You are not authorized to perform this action.")
    end
  end
end
