module Api
  class FlightsController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_all_flights : blueprinter_all_flights
    end

    def show
      flight = Flight.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_flight(flight)
                   else
                     FlightSerializer.render(flight,
                                             root: :flight)
                   end
    end

    def create
      flight = Flight.new(flight_params)
      if flight.save
        render json: { flight: flight }, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def update
      flight = Flight.find(params[:id])
      if flight&.update(flight_params)
        render json: { flight: flight }, status: :ok
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])
      if flight&.destroy
        render json: flight, status: :no_content
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    private

    def flight_params
      params.require(:flight).permit(:id,
                                     :arrives_at,
                                     :base_price,
                                     :company_id,
                                     :departs_at,
                                     :name,
                                     :no_of_seats)
    end

    def jsonapi_all_flights
      JsonapiSerializer::FlightSerializer.new(Flight.all).public_send(json_root_method)
    end

    def jsonapi_flight(flight)
      JsonapiSerializer::FlightSerializer.new(flight).json_with_root
    end

    def blueprinter_all_flights
      if root?
        FlightSerializer.render(Flight.all,
                                root: :flights)
      else
        FlightSerializer.render(Flight.all)
      end
    end
  end
end
