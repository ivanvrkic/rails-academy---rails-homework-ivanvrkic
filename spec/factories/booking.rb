FactoryBot.define do
  factory :booking do
    user { create(:user) }
    flight { create(:flight) }
    seat_price { 10 }
    no_of_seats { 10 }
  end
end
