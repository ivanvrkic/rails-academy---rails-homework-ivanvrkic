# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  password_digest :text             not null
#  token           :text             not null
#  role            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module Api
  class UserSerializer < Blueprinter::Base
    identifier :id

    field :first_name
    field :last_name
    field :email
    field :created_at
    field :updated_at
    field :role

    view :normal do
      association :bookings, blueprint: BookingSerializer
    end
  end
end
