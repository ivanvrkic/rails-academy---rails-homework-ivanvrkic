class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: exception }, status: :not_found
  end

  private

  def jsonapi_serializer?
    request.headers['HTTP_X_API_SERIALIZER'] == 'jsonapi-serializer'
  end

  def root?
    request.headers['HTTP_X_API_SERIALIZER_ROOT'] != '0'
  end

  def json_root_method
    root? ? 'json_with_root' : 'json_without_root'
  end
end
