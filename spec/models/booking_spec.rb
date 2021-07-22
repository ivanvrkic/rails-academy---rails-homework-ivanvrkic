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

RSpec.describe Booking, type: :model do
  let(:booking) { create(:booking) }

  it 'is valid when flight is not the past' do
    booking.valid?

    expect(booking.errors[:flight]).not_to include('can not be in the past')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).class_name('User') }

    it { is_expected.to belong_to(:flight).class_name('Flight') }
  end

  describe 'validations' do
    subject { booking }

    it { is_expected.to validate_presence_of(:seat_price) }
    it { is_expected.to validate_numericality_of(:seat_price) }

    it { is_expected.to validate_presence_of(:no_of_seats) }
    it { is_expected.to validate_numericality_of(:no_of_seats) }
  end
end
