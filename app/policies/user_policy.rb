class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || record_owner?
  end

  def create?
    admin? || record_owner?
  end

  def update?
    return true if admin?
    return true if user&.role == record&.role && user_owner?

    false
  end

  def destroy?
    admin? || record_owner?
  end

  def update_role?
    admin?
  end
end
