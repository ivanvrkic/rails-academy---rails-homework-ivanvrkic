module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end

    def api_headers
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    end

    def date_format(date)
      date.strftime('%FT%T.%LZ')
    end

    def flight_hash
      { name: 'Flight1',
        arrives_at: arriving_date.to_s, departs_at: departing_date.to_s,
        company_id: flights.first.company_id, base_price: 10,
        no_of_seats: 10 }
    end

    def flight_hash_response
      { name: 'Flight1',
        arrives_at: arriving_date.to_s, departs_at: departing_date.to_s,
        base_price: 10, no_of_seats: 10 }
    end

    def booking_hash
      { flight_id: bookings.first.flight_id,
        no_of_seats: 100,
        seat_price: 100,
        user_id: bookings.first.user_id }
    end

    def booking_hash_response
      { no_of_seats: 100, seat_price: 100 }
    end
  end
end
