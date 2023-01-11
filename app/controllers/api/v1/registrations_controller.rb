class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def create
    # ログインしていない状態でのみ登録可能
    render status: 403 and return if api_v1_user_signed_in?
    super
  end

  # @override
  def render_create_success
    render :json
  end
end
