# app/mailers/booking_mailer.rb
class BookingMailer < ApplicationMailer
  default from: "notifications@eventhub.com"

  def confirmation_email(booking)
    @booking = booking
    @user = booking.user
    @event = booking.event

    mail(to: @user.email, subject: "Booking Confirmed: #{@event.title}")
  end
end
