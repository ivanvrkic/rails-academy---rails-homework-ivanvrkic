module Api
  class BookingsController < ApplicationController
    before_action :auth

    def index
      render json: jsonapi_serializer? ? jsonapi_all_bookings : blueprinter_all_bookings
    end

    def show
      booking = Booking.where(user: @user, id: params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_booking(booking)
                   else
                     BookingSerializer.render(
                       booking, root: :booking
                     )
                   end
    end

    def create
      binding.pry
      booking = Booking.new({'user_id' => @user.id}.merge(booking_params))
      if booking.save
        render json: BookingSerializer.render(booking, root: :booking), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def update
      booking = Booking.where(user: @user, id: params[:id])
      if booking&.update(booking_params)
        render json: BookingSerializer.render(booking, root: :booking), status: :ok
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    def destroy
      booking = Booking.where(user: @user, id: params[:id])
      if booking&.destroy
        render json: booking, status: :no_content
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    private

    def booking_params
      params.require(:booking).permit(:flight_id,
                                      :no_of_seats,
                                      :seat_price).to_h.to_hash
    end

    def jsonapi_all_bookings
      JsonapiSerializer::BookingSerializer.new(Booking.where(user: @user)).public_send(json_root_method)
    end

    def jsonapi_booking(booking)
      JsonapiSerializer::BookingSerializer.new(booking).json_with_root
    end

    def blueprinter_all_bookings
      if root?
        BookingSerializer.render(Booking.where(user: @user),
                                 root: :bookings)
      else
        BookingSerializer.render(Booking.where(user: @user))
      end
    end

    def auth
      @token = request.headers['Authorization']
      @user = User.find_by(token: @token)
      render json: { errors: {token: ['is invalid'] }}, status: :unauthorized unless @token && @user
    end
  end
end
