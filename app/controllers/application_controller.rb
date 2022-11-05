class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Fake module → reason:https://github.com/heartcombo/devise/issues/5443
  include RackSessionFixController

  include Pundit::Authorization
  def pundit_user
    current_api_v1_user
  end

  #TODO:後々必要になりそうなのでコメントとして追加
  #skip_before_action :verify_authenticity_token
  #helper_method :current_user, :user_signed_in?
end
