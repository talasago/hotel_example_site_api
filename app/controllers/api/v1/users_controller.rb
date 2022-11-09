class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  skip_after_action :update_auth_header, only: [:destroy]

  def show
    render json: current_api_v1_user.as_json(
      only: [:email, :username, :rank, :address, :tel,
             :gender, :birthday, :notification]
    )
  end

  def destroy
    current_api_v1_user.destroy
  end
end
