module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :render_500_error
    rescue_from HotelExampleSiteApiExceptions::BadRequestError, with: :render_400_error
    rescue_from HotelExampleSiteApiExceptions::UnauthorizedError, with: :render_401_error
    rescue_from HotelExampleSiteApiExceptions::ForbiddenError, with: :render_403_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_404_error
    rescue_from HotelExampleSiteApiExceptions::ConflictError, with: :render_409_error
  end

  private

  def render_500_error(error)
    logger.unknown error
    render json: { message: 'Internal server error.' },
           status: :internal_server_error
  end

  def render_400_error(error)
    logger.error error
    render json: { message: error.message, errors: error.details }, status: :bad_request
  end

  def render_401_error(error)
    logger.error error
    render json: { message: error.message }, status: :unauthorized
  end

  def render_403_error(error)
    logger.error error
    render json: { message: error.message }, status: :forbidden
  end

  def render_404_error(error)
    logger.error error
    render json: { message: 'Not found.' }, status: :not_found
  end

  def render_409_error(error)
    logger.error error
    render json: { message: error.message }, status: :conflict
  end
end
