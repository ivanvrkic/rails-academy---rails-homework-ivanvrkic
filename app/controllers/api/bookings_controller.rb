module Api
  class BookingsController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_booking(Booking.all) : blueprinter_all_bookings
    end

    def show
      booking = Booking.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_booking(booking)
                   else
                     default_json_booking(booking)
                   end
    end

    def create
      booking = Booking.new(booking_params)
      if booking.save
        render json: default_json_booking(booking), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])
      if booking.update(booking_params)
        render json: default_json_booking(booking), status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.find(params[:id])
      if booking.destroy
        render json: booking, status: :no_content
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

    def default_json_booking(booking)
      BookingSerializer.render(booking, root: :booking, view: :normal)
    end

    def jsonapi_booking(booking)
      JsonapiSerializer::BookingSerializer.new(booking).public_send(json_root_method)
    end

    def blueprinter_all_bookings
      if root?
        BookingSerializer.render(Booking.all, root: :bookings, view: :normal)
      else
        BookingSerializer.render(Booking.all, view: :normal)
      end
    end
  end
end
