FactoryBot.define do
  factory :booking do
    user { create(:user) }
    flight { create(:flight) }
    seat_price { 99 }
    no_of_seats { 3 }
  end
end
