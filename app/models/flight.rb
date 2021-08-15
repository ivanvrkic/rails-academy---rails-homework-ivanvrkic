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
class Flight < ApplicationRecord
  belongs_to :company

  has_many :bookings, dependent: :destroy

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, scope: :company_id }

  validates :departs_at, presence: true

  validates :arrives_at, presence: true

  validates :base_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true,
                          numericality: { greater_than: 0 }

  validate :departs_is_before_arrives
  validate :not_overlapping

  scope :departs_after, -> { where('departs_at > ?', DateTime.now) }

  scope :no_of_available_seats_gteq, lambda { |seats|
                                       where('? <= flights.no_of_seats - COALESCE((
                                             SELECT SUM("bookings"."no_of_seats")
                                             FROM "bookings"
                                             WHERE "bookings"."flight_id" = "flights"."id"), 0)',
                                             seats)
                                     }

  scope :name_cont, ->(name) { where('lower(name) LIKE ?', "%#{name&.downcase}%") }

  scope :departs_at_eq, lambda { |departs_at|
                          where("departs_at >= :d::date and
                                departs_at < :d::date + interval '1 day'",
                                d: departs_at)
                        }

  def departs_is_before_arrives
    return if departs_at && arrives_at && departs_at < arrives_at

    errors.add(:departs_at, 'must be before arriving date')
  end

  def not_overlapping
    is_overlapping = Flight.where('arrives_at >= ? and
                                  ? >= departs_at and
                                  company_id = ? and
                                  not lower(name) = ?',
                                  departs_at, arrives_at, company_id, name&.downcase)
    return unless is_overlapping.exists?

    errors.add(:departs_at, "from #{self.id} #{self.departs_at} #{self.arrives_at} must not overlap with existing flights #{is_overlapping.take.id} #{is_overlapping.take.departs_at} #{is_overlapping.take.arrives_at}within the same company")
    errors.add(:arrives_at, "from #{self} must not overlap with existing flights #{is_overlapping} within the same company")
  end
end
