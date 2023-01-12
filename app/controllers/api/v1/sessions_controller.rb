class Api::V1::SessionsController < DeviseTokenAuth::SessionsController
  skip_after_action :reset_session, only: [:destroy]

  def destroy
    super
    session["warden.user.user.key"] = nil
  end

  # @override
  def render_create_success
    render :json
  end
end
