class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event
  enum :status, { pending: 0, confirmed: 1, canceled: 2 }
  validates :user_id, uniqueness: { scope: :event_id, message: "has already booked this event" }

end
