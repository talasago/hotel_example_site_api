class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  skip_after_action :update_auth_header, only: [:destroy]

  def show
    render json: generate_response_body
  end

  def destroy
    if current_api_v1_user.id.between?(1, 4)
      raise HotelExampleSiteApiExceptions::ForbiddenError.new('Users with IDs 1~4 cannot delete.')
    end

    current_api_v1_user.destroy
  end

  private

  def generate_response_body
    res = current_api_v1_user.as_json(
      only: [:email, :username, :rank, :address, :tel,
             :gender, :birthday, :notification]
    )
    res['birthday'] = res['birthday']&.gsub(/-/, '/')
    res
  end
end
