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
    relation.joins(:bookings)
            .group('flights.id, bookings.flight_id')
            .select('bookings.flight_id,
                     SUM(bookings.no_of_seats)/flights.no_of_seats::DOUBLE PRECISION as occupancy,
                     SUM(bookings.no_of_seats) as no_of_booked_seats,
                     SUM(bookings.no_of_seats*seat_price) as revenue')
  end
end
