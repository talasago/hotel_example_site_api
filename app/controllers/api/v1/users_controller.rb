class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  skip_after_action :update_auth_header, only: [:destroy]

  def show
    render json: { 'message': 'Get completed.', 'data': build_response_data }
  end

  def destroy
    if current_api_v1_user.id.between?(1, 4)
      raise HotelExampleSiteApiExceptions::ForbiddenError.new('Users with IDs 1~4 cannot delete.')
    end

    current_api_v1_user.destroy

    render status: :no_content
  end

  private

  def build_response_data
    data = current_api_v1_user.as_json(
      only: [:email, :username, :rank, :address, :tel,
             :gender, :birthday, :notification]
    )
    data['birthday'] = data['birthday']&.gsub(/-/, '/')
    data
  end

  # @override
  # devise_token_auth/lib/devise_token_auth./controllers/helpers.rb
  def render_authenticate_error
    raise HotelExampleSiteApiExceptions::UnauthorizedError
      .new('You need to sign in or sign up before continuing.')
  end
end
