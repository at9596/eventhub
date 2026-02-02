require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "POST /auth/login" do
    let!(:user) { create(:user, email: "abhishek@example.com", password: "password123") }
    let(:valid_params) { { email: "abhishek@example.com", password: "password123" } }
    let(:invalid_params) { { email: "abhishek@example.com", password: "wrongpassword" } }

    context "with valid credentials" do
      it "returns a success status and a JWT token" do
        post "/auth/login", params: valid_params

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("token")
        expect(json_response).to have_key("exp")
        expect(json_response["user"]["email"]).to eq(user.email)
      end

      it "returns a token that can be decoded" do
        post "/auth/login", params: valid_params
        token = JSON.parse(response.body)["token"]

        # Verify the token actually works with your service
        decoded = JsonWebToken.decode(token)
        expect(decoded[:user_id]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized status" do
        post "/auth/login", params: invalid_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["errors"]).to eq("Invalid email or password")
      end

      it "returns unauthorized for a non-existent email" do
        post "/auth/login", params: { email: "notfound@example.com", password: "password123" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
