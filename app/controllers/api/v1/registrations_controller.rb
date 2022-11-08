class Api::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  private

  def sign_up_params
    params.permit(:username, :email, :password, :password_confirmation, :member_rank)
  end
end
