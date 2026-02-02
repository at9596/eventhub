# spec/jobs/booking_confirmation_job_spec.rb
require 'rails_helper'

RSpec.describe BookingConfirmationJob, type: :job do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:booking) { create(:booking, user: user, event: event, status: :confirmed) }

  describe "#perform" do
    it "sends a confirmation email" do
      expect {
        described_class.perform_now(booking.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "logs an error if the booking is not found" do
      expect(Rails.logger).to receive(:error).with(/not found/)
      described_class.perform_now(999999)
    end
  end
end
