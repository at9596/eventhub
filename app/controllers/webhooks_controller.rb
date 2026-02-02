class WebhooksController < ApplicationController
  skip_before_action :authorize_request, only: [ :stripe ]

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    if event["type"] == "payment_intent.succeeded"
      intent = event["data"]["object"]
      booking = Booking.find_by(payment_intent_id: intent.id)
      if booking
        booking.update!(status: :confirmed)
        BookingConfirmationJob.perform_later(booking.id)
      end
    end
    render json: { message: "success" }, status: :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
