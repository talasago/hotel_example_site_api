module RequestSpecHelper
  def sign_up(regist_user)
    post '/api/v1/auth', params: regist_user
    get_auth_params(response)
  end

  def sign_in(params)
    post '/api/v1/auth/sign_in', params: { **params }
    get_auth_params(response)
  end

  def generate_unnecessary_params
    {
      hoge: 'hoge',
      fuga: 0,
      piyo: false,
      foo: ['foo1', 33, true],
      bar: {
        bar1: 'bar1',
        bar2: 22,
        bar3: false
      }
    }
  end

  private

  def get_auth_params(response)
    {
      'access-token': response.headers['access-token'],
      client: response.headers['client'],
      uid: response.headers['uid']
    }
  end
end
