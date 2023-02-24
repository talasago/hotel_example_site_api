class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
  skip_after_action :reset_session, only: [:destroy]

  def create
    # ログイン済みではない場合にのみログインを許可
    if api_v1_user_signed_in?
      raise HotelExampleSiteApiExceptions::UnauthorizedError
        .new('Already signed in.')
    end

    super
  end

  def destroy
    # TODO:
    ##レスポンス変えたい。
    #{
    #  "success": true
    #}
    #
    super
    session['warden.user.user.key'] = nil
  end

  # @override
  def render_create_success
    render :json
  end
end
