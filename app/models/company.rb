# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Company < ApplicationRecord
  has_many :flights, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
