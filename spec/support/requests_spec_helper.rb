module RequestSpecHelper
  def sign_up(regist_user)
    post '/api/v1/auth', params: { user: regist_user }
    get_auth_params_from_login_response_headers(response)
  end

  private

  def get_auth_params_from_login_response_headers(response)
    {
      'access-token': response.headers['access-token'],
      client: response.headers['client'],
      uid: response.headers['uid']
    }
  end
end
