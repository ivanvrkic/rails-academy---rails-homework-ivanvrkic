class ApplicationController < ActionController::Base
  include Pundit

  skip_before_action :verify_authenticity_token

  before_action :require_json
  before_action :auth

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: { errors: 'not found' }, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do |_exception|
    render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
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

  def require_json
    return if request.headers['Content-Type'] == 'application/json'

    render json: { errors: { content_type: ['not recognized'] } },
           status: :unsupported_media_type
  end

  def auth
    return if current_user && @token

    render json: { errors: { token: ['is invalid'] } },
           status: :unauthorized
  end

  def current_user
    @token = request.headers['Authorization']
    @current_user ||= User.find_by(token: request.headers['Authorization'])
  end
end
