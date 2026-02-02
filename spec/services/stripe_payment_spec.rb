require 'rails_helper'

RSpec.describe StripePayment do
  let(:user) { create(:user) }
  let(:event) { create(:event, price: 50.0) }
  let(:booking) { create(:booking, user: user, event: event) }

  describe '.create_intent' do
    let(:stripe_response) do
      double('Stripe::PaymentIntent', id: 'pi_123_test', status: 'requires_payment_method')
    end

    before do
      # We intercept the call to the Stripe Gem and return our mock object
      allow(Stripe::PaymentIntent).to receive(:create).and_return(stripe_response)
    end

    it 'calls Stripe::PaymentIntent.create with correct arguments' do
      described_class.create_intent(event, user, booking)

      # Verify that we sent the right data to Stripe
      expect(Stripe::PaymentIntent).to have_received(:create).with(
        hash_including(
          amount: 5000, # 50.0 * 100
          currency: "usd",
          metadata: {
            booking_id: booking.id,
            user_id: user.id
          }
        )
      )
    end

    it 'returns the stripe payment intent object' do
      result = described_class.create_intent(event, user, booking)

      expect(result.id).to eq('pi_123_test')
    end
  end
end
