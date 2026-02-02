class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin? || user.organizer?
  end

  def update?
    admin? || owns_event?
  end

  def destroy?
    admin? || owns_event?
  end
  private

  def owns_event?
    user.organizer? && record.organizer_id == user.id
  end
end
