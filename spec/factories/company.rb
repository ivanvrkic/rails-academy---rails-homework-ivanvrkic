FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "company11#{n}" }
  end
end
