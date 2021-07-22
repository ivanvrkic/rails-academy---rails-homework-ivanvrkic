module Api
  class BookingsController < ApplicationController
    def index
      render json: BookingSerializer.render(Booking.all, root: :bookings)
    end

    def show
      booking = Booking.find(params[:id])
      if booking
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: 'not found' }, status: :not_found
      end
    end

    def create
      binding.pry
      booking = Booking.new(booking_params)
      if booking.save
        render json: booking, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])
      if booking&.update(booking_params)
        render json: booking, status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])
      if booking&.destroy
        render json: booking, status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    private

    def booking_params
      params.require(:booking).permit(:id,
                                      :flight_id,
                                      :no_of_seats,
                                      :seat_price,
                                      :user_id)
    end
  end
end
