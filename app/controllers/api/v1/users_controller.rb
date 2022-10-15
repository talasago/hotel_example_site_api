class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  skip_after_action :update_auth_header

  def destroy
    current_api_v1_user.destroy
  end
end
