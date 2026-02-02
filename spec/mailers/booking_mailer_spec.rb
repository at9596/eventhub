require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "confirmation_email" do
    let(:user) { create(:user, email: "abhishek.dev@example.com") }
    let(:event) { create(:event, title: "Ruby on Rails Masterclass") }
    let(:booking) { create(:booking, user: user, event: event) }
    let(:mail) { BookingMailer.confirmation_email(booking) }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking Confirmed: Ruby on Rails Masterclass")
      expect(mail.to).to eq([ "abhishek.dev@example.com" ])
      expect(mail.from).to eq([ "notifications@eventhub.com" ])
    end

    it "renders the body" do
      # Check for specific content in the email body (text and html)
      expect(mail.body.encoded).to match("Booking Confirmed")
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(event.title)
    end

    it "sends an email when delivered" do
      expect {
        mail.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
