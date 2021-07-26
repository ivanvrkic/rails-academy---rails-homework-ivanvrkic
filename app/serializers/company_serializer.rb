# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CompanySerializer < Blueprinter::Base
  identifier :id
  field :name
  field :created_at
  field :updated_at
end
