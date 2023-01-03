class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController

  # @override
  def render_create_success
    render :json
  end
end
