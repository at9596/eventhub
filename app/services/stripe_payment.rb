class StripePayment
  def self.create_intent(event, user, booking)
    Stripe::PaymentIntent.create({
      amount: (event.price * 100).to_i,
      currency: "usd",
      metadata: {
        booking_id: booking.id,
        user_id: user.id
      },
      automatic_payment_methods: { enabled: true }
    })
  end
end
