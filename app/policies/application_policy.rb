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

  def admin_and_own_permission
    admin? || user_owner? || record_owner? || own_record_list_permission
  end

  def admin?
    user&.role == 'admin'
  end

  def user_owner?
    user&.id == record&.id if record.is_a?(User)
  end

  def record_owner?
    user&.id == record&.user_id if record.respond_to?(:user_id)
  end

  def own_record_list_permission
    if record.respond_to?(:take) && record&.take.respond_to?(:user_id)
      return user&.id == record&.take&.user_id
    end

    nil
  end
end
