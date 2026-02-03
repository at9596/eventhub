require 'rails_helper'

RSpec.describe "Api::V1::Bookings", type: :request do
  let(:user) { create(:user) } # Default customer
  let(:organizer) { create(:user, :organizer) }
  let(:event) { create(:event, organizer: organizer, capacity: 2) }
  let(:headers) { sign_in_as(user) }

  describe "POST /api/v1/events/:event_id/bookings" do
    let(:stripe_intent_mock) { double(id: "pi_test_123") }

    before do
      # Mock the Stripe service so we don't hit the real API
      allow(StripePayment).to receive(:create_intent).and_return(stripe_intent_mock)
    end

    context "when authorized as a customer" do
      it "creates a booking and returns a stripe intent" do
        expect {
          post "/api/v1/events/#{event.id}/bookings", headers: headers
        }.to change(Booking, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["payment_intent_id"]).to eq("pi_test_123")
      end
    end

    context "when the event is full" do
      before do
        # Create enough bookings to fill the capacity
        create_list(:booking, 2, event: event, status: :confirmed)
      end

      it "returns an error and does not create a booking" do
        expect {
          post "/api/v1/events/#{event.id}/bookings", headers: headers
        }.not_to change(Booking, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Event full")
      end
    end
  end

  describe "PATCH /api/v1/bookings/:id/cancel" do
    let!(:booking) { create(:booking, user: user, event: event) }
    let(:other_user) { create(:user) }
    let(:other_auth_headers) { sign_in_as(other_user) }

    it "allows the owner to cancel the booking" do
      patch "/api/v1/bookings/#{booking.id}/cancel", headers: sign_in_as(user)

      expect(response).to have_http_status(:ok)
      expect(booking.reload.status).to eq("canceled")
    end

    it "denies cancellation for users who don't own the booking" do
      patch "/api/v1/bookings/#{booking.id}/cancel", headers: other_auth_headers

      expect(response).to have_http_status(:forbidden)
      expect(booking.reload.status).not_to eq("canceled")
    end
  end
end
