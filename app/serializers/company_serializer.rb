class CompanySerializer < Blueprinter::Base
  identifier :id

  field :name
  field :created_at
  field :updated_at

  view :normal do
    association :flights, blueprint: FlightSerializer
  end
end
