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
class Flight < ApplicationRecord
  belongs_to :company

  has_many :bookings, dependent: :destroy

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, scope: :company_id }

  validates :departs_at, presence: true

  validates :arrives_at, presence: true

  validates :base_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true,
                          numericality: { greater_than: 0 }

  validate :departs_is_before_arrives

  def departs_is_before_arrives
    return if departs_at && arrives_at && departs_at < arrives_at

    errors.add(:departs_at, 'must be before arriving date')
  end
end