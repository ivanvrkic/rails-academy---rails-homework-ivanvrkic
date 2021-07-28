class BookingPolicy < ApplicationPolicy
  def index?
    admin_and_own_permission || record.count.zero?
  end

  def show?
    admin_and_own_permission
  end

  def create?
    admin_and_own_permission
  end

  def update?
    admin_and_own_permission
  end

  def destroy?
    admin_and_own_permission
  end

  def update_user?
    admin_permission
  end
end
