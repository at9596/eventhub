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
  # Assuming you have a JsonWebToken service to encode tokens
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  describe "authorize_request" do
    context "when a valid token is provided" do
      before do
        request.headers["Authorization"] = "Bearer #{token}"
      end

      it "sets the current_user and allows the request" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(controller.current_user).to eq(user)
      end
    end

    context "when an invalid token is provided" do
      before do
        request.headers["Authorization"] = "Bearer invalid_token"
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
      end
    end
  end

  describe "Pundit Authorization" do
    before do
      # Mocking valid authorization to reach the action
      request.headers["Authorization"] = "Bearer #{token}"
    end

    it "rescues from Pundit::NotAuthorizedError" do
      routes.draw { get "check_pundit" => "anonymous#check_pundit" }
      get :check_pundit

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["errors"]).to eq("You are not authorized to perform this action.")
    end
  end
end
