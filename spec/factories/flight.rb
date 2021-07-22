FactoryBot.define do
  factory :flight do
    company { create(:company) }
    sequence(:name) { |n| "Flight10#{n}" }
    departs_at { DateTime.current + 7 }
    arrives_at { DateTime.current + 8 }
    base_price { 10 }
    no_of_seats { 10 }
  end
end
