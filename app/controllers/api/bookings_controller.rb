module Api
  class BookingsController < ApplicationController
    def index
      booking = policy_scope(Booking).includes(:flight, :user)
                                     .joins(:flight)
                                     .order('departs_at ASC, name ASC')

      booking = booking.where('flights.departs_at > ?', DateTime.now) if params[:filter] == 'active'

      render json: response_booking(booking)
    end

    def show
      booking = Booking.find(params[:id])

      authorize booking

      render json: response_booking(booking)
    end

    def create
      booking = Booking.new(merged_booking_params)

      authorize booking

      if booking.save
        render json: default_json_booking(booking), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.find(params[:id])

      authorize booking

      if booking.update(booking_params)
        render json: default_json_booking(booking), status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.find(params[:id])

      authorize booking

      if booking.destroy
        render json: booking, status: :no_content
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    private

    def response_booking(booking)
      if jsonapi_serializer?
        jsonapi_booking(booking)
      else
        default_json_booking(booking)
      end
    end

    def booking_params
      if current_user&.admin?
        admin_user_params
      else
        regular_user_params
      end
    end

    def regular_user_params
      params.require(:booking).permit(:flight_id,
                                      :no_of_seats,
                                      :seat_price)
    end

    def admin_user_params
      params.require(:booking).permit(:flight_id,
                                      :no_of_seats,
                                      :seat_price,
                                      :user_id)
    end

    def default_json_booking(booking)
      if root?
        root_name = booking.is_a?(Booking) ? :booking : :bookings
        BookingSerializer.render(booking, root: root_name, view: :normal)
      else
        BookingSerializer.render(booking, view: :normal)
      end
    end

    def merged_booking_params
      { 'user_id' => @current_user&.id }.merge(booking_params)
    end

    def jsonapi_booking(booking)
      JsonapiSerializer::BookingSerializer.new(booking).public_send(json_root_method)
    end
  end
end
