require 'rails_helper'

RSpec.describe EventPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:organizer) { create(:user, :organizer) }
  let(:other_organizer) { create(:user, :organizer) }
  let(:customer) { create(:user) } # Default role is customer

  let(:event) { create(:event, organizer: organizer) }

  permissions :index?, :show? do
    it "allows everyone to view events" do
      expect(subject).to permit(customer, event)
      expect(subject).to permit(nil, event) # Even unauthenticated users if your app allows
    end
  end

  permissions :create? do
    it "allows admins to create events" do
      expect(subject).to permit(admin, Event.new)
    end

    it "allows organizers to create events" do
      expect(subject).to permit(organizer, Event.new)
    end

    it "denies customers from creating events" do
      expect(subject).not_to permit(customer, Event.new)
    end
  end

  permissions :update?, :destroy? do
    it "allows admins to modify any event" do
      expect(subject).to permit(admin, event)
    end

    it "allows the owner organizer to modify their own event" do
      expect(subject).to permit(organizer, event)
    end

    it "denies an organizer from modifying someone else's event" do
      expect(subject).not_to permit(other_organizer, event)
    end

    it "denies customers from modifying events" do
      expect(subject).not_to permit(customer, event)
    end
  end
end
