# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'is invalid without an name' do
    company = described_class.new(name: nil)
    company.valid?
    expect(company.errors[:name]).to include("can't be blank")
  end

  it 'is invalid when name is already taken' do
    described_class.create!(name: 'Company')
    company = described_class.new(name: 'Company')
    company.valid?
    expect(company.errors[:name]).to include('has already been taken')
  end

  it 'is invalid when name is already taken (case insensitive)' do
    described_class.create!(name: 'Company')
    company = described_class.new(name: 'company')
    company.valid?
    expect(company.errors[:name]).to include('has already been taken')
  end
end
