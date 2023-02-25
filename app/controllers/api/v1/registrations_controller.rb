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
    render :json
  end
end
