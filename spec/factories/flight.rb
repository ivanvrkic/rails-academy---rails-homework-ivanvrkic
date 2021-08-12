FactoryBot.define do
  factory :flight do
    company { create(:company) }
    sequence(:name) { |n| "Flight10#{n}" }
    sequence(:departs_at) { |n| n.days.from_now.to_s }
    sequence(:arrives_at) { |n| ((n + 1).days.from_now - 1).to_s }
    base_price { 10 }
    no_of_seats { 10 }
  end
end
