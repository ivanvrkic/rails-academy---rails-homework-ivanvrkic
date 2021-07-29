class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || user_is_owner?
  end

  def create?
    admin? || user_is_owner?
  end

  def update?
    return true if admin?
    return true if user&.role == record&.role && user_is_owner?

    false
  end

  def destroy?
    admin? || user_is_owner?
  end
end