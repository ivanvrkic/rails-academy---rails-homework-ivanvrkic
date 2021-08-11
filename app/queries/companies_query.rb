class CompaniesQuery
  attr_accessor :relation

  def initialize(relation: Company.all)
    @relation = relation
  end

  def with_stats
    relation.joins(flights: :bookings)
            .group('companies.id, flights.company_id')
            .select('flights.company_id,
                     AVG(bookings.seat_price)::DOUBLE PRECISION as average_price_of_seats,
                     SUM(bookings.no_of_seats) as total_no_of_booked_seats,
                     SUM(bookings.no_of_seats*bookings.seat_price) as total_revenue')
  end
end
