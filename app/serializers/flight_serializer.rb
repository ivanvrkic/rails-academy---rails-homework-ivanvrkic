class FlightSerializer < Blueprinter::Base
  identifier :id
  field :name
  field :no_of_seats
  field :base_price
  field :departs_at
  field :arrives_at
  field :created_at
  field :updated_at
  association :company, blueprint: CompanySerializer
end
