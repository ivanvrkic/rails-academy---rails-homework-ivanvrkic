# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  password_digest :text             not null
#  token           :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it 'is invalid when email format is invalid' do
    user_invalid = build(:user, email: 'myemail')

    user_invalid.valid?
    binding
    expect(user_invalid.errors[:email]).to include('is invalid')
  end

  describe 'associations' do
    it { is_expected.to have_many(:bookings).class_name('Booking') }
  end

  describe 'validations' do
    subject { user }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'password' do
    context 'when valid' do
      it 'successfully changes' do
        user.update(password: 'securepasssword123', password_confirmation: 'securepasssword123')

        expect(user.valid?).to be true
        expect(user.authenticate('securepasssword123')).to be_a(described_class)
      end
    end

    context 'when blank' do
      it 'does not change' do
        user.update(password: ' ', password_confirmation: ' ')

        expect(user.valid?).to be false
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    context 'when nil' do
      it 'does not change' do
        user.update(password: nil, password_confirmation: nil)

        expect(user.valid?).to be false
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    context 'when confirmation passoword does not match' do
      it 'does not change' do
        user.update(password: 'not', password_confirmation: 'matching')

        expect(user.valid?).to be false
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end
end
