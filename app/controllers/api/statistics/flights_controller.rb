module Api
  module Statistics
    class FlightsController < ApplicationController
      skip_before_action :require_json

      def index
        flight = FlightsQuery.new.with_stats
        authorize [:statistics, flight]
        render json: default_json_flight(flight)
      end

      private

      def default_json_flight(flight)
        if root?
          root_name = flight.is_a?(Flight) ? :flight : :flights
          Statistics::FlightSerializer.render(flight, root: root_name)
        else
          Statistics::FlightSerializer.reder(flight)
        end
      end
    end
  end
end
