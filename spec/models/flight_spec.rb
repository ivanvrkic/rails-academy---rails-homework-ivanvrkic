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
  let(:company) { Company.create!(name: 'Company') }

  it 'is invalid without a name' do
    flight = described_class.new(name: nil)

    flight.valid?

    expect(flight.errors[:name]).to include("can't be blank")
  end

  it 'is invalid when name is already taken in the scope of same company' do
    described_class.create!(name: 'Flight', company_id: company.id, departs_at: DateTime.current,
                            arrives_at: DateTime.current + 1, base_price: 10, no_of_seats: 10)
    flight = described_class.new(name: 'Flight', company_id: company.id)

    flight.valid?

    expect(flight.errors[:name]).to include('has already been taken')
  end

  it 'is invalid when name is already taken (case insensitive) in the scope of same company' do
    described_class.create!(name: 'Flight', company_id: company.id, departs_at: DateTime.current,
                            arrives_at: DateTime.current + 1, base_price: 10, no_of_seats: 10)
    flight = described_class.new(name: 'flight', company_id: company.id)

    flight.valid?

    expect(flight.errors[:name]).to include('has already been taken')
  end

  it 'is invalid without a departing date and time' do
    flight = described_class.new(departs_at: nil)

    flight.valid?

    expect(flight.errors[:departs_at]).to include("can't be blank")
  end

  it 'is invalid without a arriving date and time' do
    flight = described_class.new(arrives_at: nil)

    flight.valid?

    expect(flight.errors[:arrives_at]).to include("can't be blank")
  end

  it 'is invalid without a base price' do
    flight = described_class.new(base_price: nil)

    flight.valid?

    expect(flight.errors[:base_price]).to include("can't be blank")
  end

  it 'is invalid when base price is not a number' do
    flight = described_class.new(base_price: 'a')

    flight.valid?

    expect(flight.errors[:base_price]).to include('is not a number')
  end

  it 'is invalid when base price is not greater than 0' do
    flight = described_class.new(base_price: -2)

    flight.valid?

    expect(flight.errors[:base_price]).to include('must be greater than 0')
  end

  it 'is invalid without a number of seats' do
    flight = described_class.new(no_of_seats: nil)

    flight.valid?

    expect(flight.errors[:no_of_seats]).to include("can't be blank")
  end

  it 'is invalid when number of seats is not a number' do
    flight = described_class.new(no_of_seats: 'a')

    flight.valid?

    expect(flight.errors[:no_of_seats]).to include('is not a number')
  end

  it 'is invalid when number of seats is not greater than 0' do
    flight = described_class.new(no_of_seats: -2)

    flight.valid?

    expect(flight.errors[:no_of_seats]).to include('must be greater than 0')
  end

  it 'is invalid when arriving date is before departing date' do
    flight = described_class.new(departs_at: DateTime.current, arrives_at: DateTime.current - 1)

    flight.valid?

    expect(flight.errors[:departs_at]).to include('must be before arriving date')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company).class_name('Company') }

    it { is_expected.to have_many(:bookings).class_name('Booking') }
  end

  describe 'validations' do
    subject { FactoryBot.build(:flight) }

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
