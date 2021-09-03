class FlightsQuery
  attr_accessor :relation

  def initialize(relation: Flight.all)
    @relation = relation
  end

  def filter_by(filter)
    filter.each do |key, value|
      @relation = @relation.public_send(key, value) if value.present?
    end

    relation
  end

  def with_stats
    relation.left_outer_joins(:bookings)
            .group('flights.id, bookings.flight_id')
            .select('flights.id,
                    COALESCE(SUM(bookings.no_of_seats)/flights.no_of_seats::DOUBLE PRECISION, 0)
                    as occupancy,
                    COALESCE(SUM(bookings.no_of_seats),0) as no_of_booked_seats,
                    COALESCE(SUM(bookings.no_of_seats*seat_price),0) as revenue')
  end
end
