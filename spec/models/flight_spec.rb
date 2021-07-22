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

RSpec.describe Flight, type: :model do
  let(:flight) { create(:flight) }

  it 'is valid when departing date is before arriving date' do
    flight.valid?

    expect(flight.errors[:departs_at]).not_to include('must be before arriving date')
  end

  it 'is invalid when arriving date is before departing date' do
    flight_inv = described_class.new(departs_at: DateTime.current, arrives_at: DateTime.current - 1)

    flight_inv.valid?

    expect(flight_inv.errors[:departs_at]).to include('must be before arriving date')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company).class_name('Company') }

    it { is_expected.to have_many(:bookings).class_name('Booking') }
  end

  describe 'validations' do
    subject { flight }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }

    it { is_expected.to validate_presence_of(:departs_at) }

    it { is_expected.to validate_presence_of(:arrives_at) }

    it { is_expected.to validate_presence_of(:base_price) }
    it { is_expected.to validate_numericality_of(:base_price) }

    it { is_expected.to validate_presence_of(:no_of_seats) }
    it { is_expected.to validate_numericality_of(:no_of_seats) }
  end
end
