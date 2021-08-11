# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string
#  no_of_seats :integer
#  base_price  :integer
#  departs_at  :datetime
#  arrives_at  :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Api
  class FlightSerializer < Blueprinter::Base
    identifier :id

    field :name
    field :no_of_seats
    field :base_price
    field :departs_at
    field :arrives_at
    field :created_at
    field :updated_at

    view :normal do
      association :company, blueprint: CompanySerializer

      association :bookings, blueprint: BookingSerializer

      field :no_of_booked_seats do |flight|
        flight.bookings.sum(:no_of_seats)
      end

      field :company_name do |flight|
        flight.company.name
      end

      field :current_price do |flight|
        days_before_departing = (flight.departs_at - Time.zone.now).to_i / 1.day
        if days_before_departing >= 15
          flight.base_price
        elsif days_before_departing <= 0
          2 * flight.base_price
        else
          (flight.base_price * (1 + (15 - days_before_departing) / 15.to_f)).to_i
        end
      end
    end
  end
end
