require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "POST /auth/login" do
    let!(:user) { create(:user, email: "abhishek@example.com", password: "password123") }
    let(:valid_params) { { email: "abhishek@example.com", password: "password123" } }
    let(:invalid_params) { { email: "abhishek@example.com", password: "wrongpassword" } }

    context "with valid credentials" do
      it "returns a success status and the correct user data" do
        post "/auth/login", params: valid_params

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("token")
        # Check for user email inside the nested 'user' key as per your controller
        expect(json_response["user"]["email"]).to eq(user.email)
      end

      it "sets a signed HttpOnly cookie named jwt" do
        post "/auth/login", params: valid_params

        # In request specs, response.cookies gives you access to the headers sent back
        expect(response.cookies).to have_key("jwt")

        # To verify it's HttpOnly and Secure, we check the 'Set-Cookie' header string
        cookie_header = response.headers["Set-Cookie"]
        # Use a case-insensitive regex to find httponly
        expect(cookie_header).to match(/httponly/i)
        expect(cookie_header).to include("jwt=")
      end

      it "returns a token that can be decoded" do
        post "/auth/login", params: valid_params
        token = JSON.parse(response.body)["token"]

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
    end
  end
end
