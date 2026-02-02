require 'rails_helper'

RSpec.describe BookingPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user) } # Default is customer
  let(:other_user) { create(:user) }
  let(:booking) { create(:booking, user: customer) }

  permissions :create? do
    it "allows access if user is a customer" do
      expect(subject).to permit(customer, Booking.new)
    end

    it "denies access if user is an admin" do
      # Based on your policy, only customers can create
      expect(subject).not_to permit(admin, Booking.new)
    end
  end

  permissions :show?, :cancel? do
    it "allows access to an admin" do
      expect(subject).to permit(admin, booking)
    end

    it "allows access to the owner of the booking" do
      expect(subject).to permit(customer, booking)
    end

    it "denies access to a user who does not own the booking" do
      expect(subject).not_to permit(other_user, booking)
    end
  end
end
