# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:flights).class_name('Flight') }
  end

  describe 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
