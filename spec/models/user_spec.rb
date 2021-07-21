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
#
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is invalid without a first name' do
    user = described_class.new(first_name: nil)

    user.valid?

    expect(user.errors[:first_name]).to include("can't be blank")
  end

  it 'is invalid when first name is too short' do
    user = described_class.new(first_name: 'a')

    user.valid?

    expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
  end

  it 'is invalid without an email' do
    user = described_class.new(email: nil)

    user.valid?

    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid when email is already taken' do
    described_class.create!(first_name: 'User', email: 'user@email.com')
    user = described_class.new(email: 'user@email.com')

    user.valid?

    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid when email is already taken (case insensitive)' do
    described_class.create!(first_name: 'User', email: 'user@email.com')
    user = described_class.new(email: 'User@email.com')

    user.valid?

    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid when email format is invalid' do
    user = described_class.new(email: 'myemail')

    user.valid?

    expect(user.errors[:email]).to include('is invalid')
  end
end
