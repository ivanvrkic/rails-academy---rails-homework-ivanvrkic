class BookingPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        user.bookings
      end
    end

    private

    attr_reader :user, :scope
  end

  def show?
    admin? || record_owner?
  end

  def create?
    admin? || record_owner?
  end

  def update?
    return true if admin?
    return true if user == record&.user && record_owner?

    false
  end

  def destroy?
    admin? || record_owner?
  end

end
