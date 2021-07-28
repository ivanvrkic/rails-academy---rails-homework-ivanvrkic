class CompanyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin_permission
  end

  def update?
    admin_permission
  end

  def destroy?
    admin_permission
  end
end
