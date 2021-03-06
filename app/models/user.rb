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
class User < ApplicationRecord
  has_secure_password
  has_secure_token
  has_many :bookings, dependent: :destroy

  # validates :password, presence: true

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  validates :first_name, presence: true,
                         length: { minimum: 2 }

  def admin?
    role == 'admin'
  end
end
