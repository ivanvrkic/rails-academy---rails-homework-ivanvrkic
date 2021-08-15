FactoryBot.define do
  factory :flight do
    company { create(:company) }
    sequence(:name) { |n| "Flight10#{999 - n}" }
    sequence(:departs_at) { |i| ((i*2).days.from_now + 1.hour).to_s }
    sequence(:arrives_at) { |k| ((k*2).days.from_now + 2.hour).to_s }
    base_price { 10 }
    no_of_seats { 10 }
  end
end
