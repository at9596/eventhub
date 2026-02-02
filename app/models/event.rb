class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :bookings, dependent: :destroy
  validates :title, :start_time, presence: true
  validates :capacity, numericality: { only_integer: true }

  def seats_available?
    bookings.confirmed.count < capacity
  end
end
