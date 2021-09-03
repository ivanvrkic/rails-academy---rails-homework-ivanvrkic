module Statistics
  class CompanyPolicy < ApplicationPolicy
    def index?
      admin?
    end
  end
end
