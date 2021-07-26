# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string
#  no_of_seats :integer
#  base_price  :integer
#  departs_at  :datetime
#  arrives_at  :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
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
