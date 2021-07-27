FactoryBot.define do
  factory :flight do
    company { create(:company) }
    sequence(:name) { |n| "Flight10#{n}" }
    departs_at { 7.days.from_now.to_s }
    arrives_at { 8.days.from_now.to_s }
    base_price { 10 }
    no_of_seats { 10 }
  end
end
