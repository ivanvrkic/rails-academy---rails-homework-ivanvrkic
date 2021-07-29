class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def admin?
    user&.role == 'admin'
  end

  def user_owner?
    user&.id == record&.id if record.is_a?(User)
  end

  def record_owner?
    user&.id == record&.user_id if record.respond_to?(:user_id)
  end
end
