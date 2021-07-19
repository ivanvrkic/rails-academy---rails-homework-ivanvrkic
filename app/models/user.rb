# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  first_name :string
#  last_name  :string
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  validates :first_name, presence: true
  validates :first_name, length: { minimum: 2 }
end
