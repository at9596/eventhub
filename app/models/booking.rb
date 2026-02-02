class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event
  enum :status, { pending: 0, confirmed: 1, canceled: 2 }
  validates :user_id, uniqueness: { scope: :event_id, message: "has already booked this event" }
  # Ensure that if the status is confirmed, a payment ID must exist
  validates :payment_intent_id, presence: true, if: :confirmed?
end
