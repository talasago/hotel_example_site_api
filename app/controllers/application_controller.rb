class ApplicationController < ActionController::API
  # TODO:別ファイル分割
  rescue_from StandardError, with: :render_500_error
  rescue_from HotelExampleSiteApiExceptions::UnauthorizedError, with: :render_401_error
  rescue_from HotelExampleSiteApiExceptions::BadRequestError, with: :render_400_error

  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization
  # Fake module → reason:https://github.com/heartcombo/devise/issues/5443
  include RackSessionFixController

  before_action :configure_permitted_parameters, if: :devise_controller?

  def pundit_user
    current_api_v1_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [:email, :password, :username, :rank, :address, :tel, :gender,
                       :birthday, :notification]
    )
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
end
