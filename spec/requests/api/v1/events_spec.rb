require 'rails_helper'

RSpec.describe "Api::V1::Events", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:organizer) { create(:user, :organizer) }
  let(:customer) { create(:user, role: :customer) }

  let!(:event) { create(:event, organizer: organizer) }

  let(:valid_attributes) do
    {
      event: {
        title: "Advanced Ruby Patterns",
        start_time: Time.now + 1.day,
        capacity: 50,
        price: 99.99
      }
    }
  end

  describe "GET /api/v1/events" do
    it "returns a successful response for any authenticated user" do
      get "/api/v1/events", headers: auth_headers(customer)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "POST /api/v1/events" do
    context "as an organizer" do
      it "creates a new event" do
        expect {
          post "/api/v1/events", params: valid_attributes, headers: auth_headers(organizer)
        }.to change(Event, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "as a customer" do
      it "denies event creation with a forbidden status" do
        post "/api/v1/events", params: valid_attributes, headers: auth_headers(customer)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/v1/events/:id" do
    it "allows the owner organizer to update the event" do
      patch "/api/v1/events/#{event.id}",
            params: { event: { title: "Updated Title" } },
            headers: auth_headers(organizer)

      expect(response).to have_http_status(:ok)
      expect(event.reload.title).to eq("Updated Title")
    end

    it "denies an organizer from updating someone else's event" do
      other_organizer = create(:user, :organizer)
      patch "/api/v1/events/#{event.id}",
            params: { event: { title: "Hacked Title" } },
            headers: auth_headers(other_organizer)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/events/:id" do
    it "allows an admin to delete any event" do
      expect {
        delete "/api/v1/events/#{event.id}", headers: auth_headers(admin)
      }.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to include("successfully deleted")
    end
  end
end
