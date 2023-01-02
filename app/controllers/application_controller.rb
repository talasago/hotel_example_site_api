class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization
  # Fake module → reason:https://github.com/heartcombo/devise/issues/5443
  include RackSessionFixController

  before_action :configure_permitted_parameters, if: :devise_controller?

  def pundit_user
    current_api_v1_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :username, :rank, :address, :tel, :gender,
                  :birthday, :notification])
  end
end
