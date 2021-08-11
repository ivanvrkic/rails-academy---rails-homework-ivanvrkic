module Api
  class FlightsController < ApplicationController
    skip_before_action :auth, only: [:index, :show]

    def index
      flight = Flight.includes(:bookings, :company)
                     .departs_after
                     .order('departs_at ASC, name ASC, created_at ASC')
      render json: response_flight(filter_flights(flight))
    end

    def show
      flight = Flight.find(params[:id])
      render json: response_flight(flight)
    end

    def create
      flight = Flight.new(flight_params)

      authorize flight

      if flight.save
        render json: default_json_flight(flight), status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def update
      flight = Flight.find(params[:id])

      authorize flight

      if flight.update(flight_params)
        render json: default_json_flight(flight), status: :ok
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])

      authorize flight

      if flight.destroy
        render json: flight, status: :no_content
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    private

    def filter_flights(flight)
      FlightsQuery.new(relation: flight).filter_by(filtering_params)
    end

    def filtering_params
      params.slice(:name_cont, :departs_at_eq, :no_of_available_seats_gteq)
    end

    def response_flight(flight)
      if jsonapi_serializer?
        jsonapi_flight(flight)
      else
        default_json_flight(flight)
      end
    end

    def flight_params
      params.require(:flight).permit(:id,
                                     :arrives_at,
                                     :base_price,
                                     :company_id,
                                     :departs_at,
                                     :name,
                                     :no_of_seats)
    end

    def default_json_flight(flight)
      if root?
        root_name = flight.is_a?(Flight) ? :flight : :flights
        FlightSerializer.render(flight, root: root_name, view: :normal)
      else
        FlightSerializer.render(flight, view: :normal)
      end
    end

    def jsonapi_flight(flight)
      JsonapiSerializer::FlightSerializer.new(flight).public_send(json_root_method)
    end

    def blueprinter_all_flights
      if root?
        FlightSerializer.render(Flight.all, root: :flights, view: :normal)
      else
        FlightSerializer.render(Flight.all, view: :normal)
      end
    end
  end
end
