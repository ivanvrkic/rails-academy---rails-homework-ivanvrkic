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
    booked = no_of_seats.to_i + total_booked_seats
    booked -= Booking.find(id).no_of_seats if id
    return if booked <= flight&.no_of_seats.to_i

    errors.add(:flight, 'can not be overbooked')
  end

  def total_booked_seats
    flight&.bookings&.sum(:no_of_seats).to_i
  end
end
