# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer
#  flight_id   :bigint
#  user_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :flight

  validates :seat_price, presence: true
  validates :seat_price, numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true
  validates :no_of_seats, numericality: { greater_than: 0 }

  validate :departs_is_not_past

  def departs_is_not_past
    return if flight&.departs_at && flight.departs_at > DateTime.current

    errors.add(:flight, 'can not be in the past')
  end
end
