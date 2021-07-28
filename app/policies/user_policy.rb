class UserPolicy < ApplicationPolicy
  def index?
    admin_permission
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

  def update_role?
    admin_permission
  end
end
