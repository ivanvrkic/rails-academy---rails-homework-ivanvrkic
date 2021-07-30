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
    admin? || user_is_owner?
  end

  def destroy?
    admin? || user_is_owner?
  end

  private

  def user_is_owner?
    user.id == record&.id
  end
end
