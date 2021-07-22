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
# rspe

RSpec.describe User, type: :model do
  it 'is invalid when email format is invalid' do
    user = described_class.new(email: 'myemail')

    user.valid?

    expect(user.errors[:email]).to include('is invalid')
  end

  describe 'associations' do
    it { is_expected.to have_many(:bookings).class_name('Booking') }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end
end
