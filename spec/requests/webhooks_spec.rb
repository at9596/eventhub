# spec/requests/webhooks_spec.rb
require 'rails_helper'

RSpec.describe "Webhooks", type: :request do
  describe "POST /webhooks/stripe" do
    let(:booking) { create(:booking, status: :pending) }
    let(:payload) do
      {
        type: "payment_intent.succeeded",
        data: {
          object: {
            id: booking.payment_intent_id,
            metadata: { booking_id: booking.id }
          }
        }
      }.to_json
    end

    before do
      allow(Stripe::Webhook).to receive(:construct_event).and_return(JSON.parse(payload))
    end

    it "updates the booking status to confirmed" do
      post "/webhooks/stripe", params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => "mock" }

      expect(booking.reload.status).to eq("confirmed")
    end

    it "enqueues a BookingConfirmationJob" do
      expect {
        post "/webhooks/stripe", params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => "mock" }
      }.to have_enqueued_job(BookingConfirmationJob).with(booking.id)
    end
  end
end
