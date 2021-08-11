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

  validates :seat_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true,
                          numericality: { greater_than: 0 }

  validate :departs_is_not_past
  validate :not_overbooked

  def departs_is_not_past
    return if flight&.departs_at && flight.departs_at > DateTime.current

    errors.add(:flight, 'can not be in the past')
  end

  def not_overbooked
    if no_of_seats.to_i + total_booked_no_of_seats <= Flight.find(flight&.id)&.no_of_seats.to_i
      return
    end

    errors.add(:flight, 'can not be overbooked')
  end
  def total_booked_no_of_seats
    Flight.find(flight&.id)&.bookings&.sum(:no_of_seats).to_i
  end
end
