module Statistics
  class FlightPolicy < ApplicationPolicy
    def index?
      admin?
    end
  end
end
