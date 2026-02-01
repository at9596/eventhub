class User < ApplicationRecord
  has_secure_password
  enum :role, { admin: 0, organizer: 1, customer: 2 }
  has_many :events, foreign_key: :organizer_id, dependent: :destroy
  has_many :bookings, dependent: :destroy
  validates :email, presence: true
end
