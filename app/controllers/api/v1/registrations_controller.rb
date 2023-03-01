class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def create
    # ログインしていない状態でのみ登録可能
    if api_v1_user_signed_in?
      raise HotelExampleSiteApiExceptions::ForbiddenError.new('Cannot sign on why you are already signed in.')
    end

    super
  end

  # @override
  def render_create_success
    render json: { message: 'Create completed.' }
  end

  protected

  # @override
  def render_error(status, message, _ = nil)
    render json: { message: message }, status: status
  end

  # @override
  def render_create_error
    render json: {
      message: I18n.t('errors.messages.validate_sign_up_params')
    }, status: 422
  end
end
