class ApplicationController < ActionController::API
  #TODO:後々必要になりそうなのでコメントとして追加
  #include DeviseTokenAuth::Concerns::SetUserByToken
  #skip_before_action :verify_authenticity_token
  #helper_method :current_user, :user_signed_in?
end
