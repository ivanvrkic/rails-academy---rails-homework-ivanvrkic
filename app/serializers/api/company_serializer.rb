# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Api
  class CompanySerializer < Blueprinter::Base
    identifier :id

    field :name
    field :created_at
    field :updated_at

    view :normal do
      association :flights, blueprint: FlightSerializer

      field :no_of_active_flights do |company|
        company.flights.departs_after.count
      end
    end
  end
end
