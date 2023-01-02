class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Fake module → reason:https://github.com/heartcombo/devise/issues/5443
  include RackSessionFixController

  include Pundit::Authorization
  def pundit_user
    current_api_v1_user
  end
end
