require 'json'

class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  skip_after_action :update_auth_header, only: [:destroy]

  def show
    # 取得する列を指定
    current_user_data = JSON.parse(
      current_api_v1_user.to_json(
        only: [:email, :username, :rank, :address, :tel,
               :gender, :birthday, :notification]
      )
    )

    render json: { user: current_user_data }
  end

  def destroy
    current_api_v1_user.destroy
  end
end
