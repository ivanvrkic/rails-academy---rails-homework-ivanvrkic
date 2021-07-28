FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@email.com" }
    first_name { 'User' }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { nil }
  end
end
