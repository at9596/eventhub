class BookingConfirmationJob < ApplicationJob
  queue_as :default

  # Solid Queue handles retries automatically if you configure it,
  # but you can also define them here:
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    if booking.nil?
      Rails.logger.error "Booking not found with ID: #{booking_id}"
      return
    end

    if booking && booking.status == "confirmed"
      BookingMailer.confirmation_email(booking).deliver_now
      Rails.logger.info "Solid Queue: Email sent for Booking ##{booking_id}"
    end
  end
end
