require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /auth/signup" do
    let(:valid_attributes) do
      {
        name: "Abhishek Tanwar",
        email: "abhishek.dev@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "customer"
      }
    end

    let(:invalid_attributes) do
      {
        name: "Abhishek",
        email: "not-an-email", # Invalid email format
        password: "pass",
        password_confirmation: "mismatch"
      }
    end

    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post "/auth/signup", params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "returns a created status and a JWT token" do
        post "/auth/signup", params: valid_attributes

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("token")
        expect(json_response["user"]["email"]).to eq("abhishek.dev@example.com")
      end
    end

    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post "/auth/signup", params: invalid_attributes
        }.to_not change(User, :count)
      end

      it "returns an unprocessable entity status with error messages" do
        post "/auth/signup", params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
