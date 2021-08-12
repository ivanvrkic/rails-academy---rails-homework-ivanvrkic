class CompaniesQuery
  attr_accessor :relation

  def initialize(relation: Company.all)
    @relation = relation
  end

  def with_stats
    relation.left_outer_joins(flights: :bookings)
            .group('companies.id, flights.company_id')
            .select('companies.id,
                    COALESCE(AVG(CASE
                      WHEN bookings.seat_price IS NOT NULL THEN bookings.seat_price
                      ELSE flights.base_price
                    END )::DOUBLE PRECISION,0)
                     as average_price_of_seats,
                     COALESCE(SUM(bookings.no_of_seats),0) as total_no_of_booked_seats,
                     COALESCE(SUM(bookings.no_of_seats*bookings.seat_price),0) as total_revenue')
  end
end
