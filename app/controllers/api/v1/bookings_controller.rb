class Api::V1::BookingsController < ApplicationController
  before_action :set_event, only: [ :create ]
  before_action :set_booking, only: [ :show, :cancel ]

  def create
    booking = @event.bookings.new(user: current_user, status: :pending)
    authorize booking
      Booking.transaction do
        raise Pundit::NotAuthorizedError, "Event full" unless @event.seats_available?
        # 1. Save the booking first to get an ID
        booking.save!
        payment_intent = StripePayment.create_intent(@event, current_user, booking)
        # 3. Store the Stripe Intent ID on your booking record
        booking.update!(payment_intent_id: payment_intent.id)
      end
    render json: booking, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    authorize @booking
    render json: @booking
  end

  def cancel
    authorize @booking
    @booking.update!(status: :canceled)
    render json: @booking
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
