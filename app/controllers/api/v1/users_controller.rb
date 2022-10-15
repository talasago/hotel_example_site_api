class Api::V1::UsersController < ApplicationController
  before_action :set_user

  def destroy
    @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
