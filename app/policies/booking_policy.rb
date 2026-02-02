class BookingPolicy < ApplicationPolicy
  def create?
    user.customer?
  end

  def show?
    admin? || record.user_id == user.id
  end

  def cancel?
    admin? || record.user_id == user.id
  end
end