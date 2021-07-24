module Api
  class FlightsController < ApplicationController
    def index
      render json: FlightSerializer.render(Flight.all, root: :flights)
    end

    def show
      flight = Flight.find(params[:id])
      render json: FlightSerializer.render(flight, root: :flight)
    end

    def create
      flight = Flight.new(flight_params)
      if flight.save
        render json: flight, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def update
      flight = Flight.find(params[:id])
      if flight&.update(flight_params)
        render json: flight, status: :ok
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    def destroy
      flight = Flight.find(params[:id])
      if flight&.destroy
        render json: flight, status: :ok
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
  end
end
