# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer
#  booking_id   :bigint
#  user_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Booking, type: :model do
  it 'is invalid without a seat price' do
    booking = described_class.new(seat_price: nil)
    booking.valid?
    expect(booking.errors[:seat_price]).to include("can't be blank")
  end
  it 'is invalid when seat price is not a number' do
    booking = described_class.new(seat_price: "a")
    booking.valid?
    expect(booking.errors[:seat_price]).to include("is not a number")
  end
  it 'is invalid when seat price is not greater than 0' do
    booking = described_class.new(seat_price: -2)
    booking.valid?
    expect(booking.errors[:seat_price]).to include("must be greater than 0")
  end
  it 'is invalid without a number of seats' do
    booking = described_class.new(no_of_seats: nil)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include("can't be blank")
  end
  it 'is invalid when number of seats is not a number' do
    booking = described_class.new(no_of_seats: "a")
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include("is not a number")
  end
  it 'is invalid when number of seats is not greater than 0' do
    booking = described_class.new(no_of_seats: -2)
    booking.valid?
    expect(booking.errors[:no_of_seats]).to include("must be greater than 0")
  end
  it 'is invalid when flight is in the past' do
    company=Company.create!(name:'Company1')
    flight= Flight.create!(name: 'Flight1',company_id:company.id,departs_at:DateTime.current-1, arrives_at:DateTime.current+1, base_price:10)
    booking = described_class.new(flight_id:flight.id)
    booking.valid?
    expect(booking.errors[:flight]).to include('can not be in the past')
  end
end
