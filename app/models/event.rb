class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :bookings, dependent: :destroy
  validates :title, :start_time, :capacity, presence: true, numericality: { greater_than: 0 }

  def seats_available?
    bookings.confirmed.count < capacity
  end
end
