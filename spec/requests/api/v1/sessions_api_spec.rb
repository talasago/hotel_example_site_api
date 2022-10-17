require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Sessions', type: :request do
  describe 'login' do
    let(:user) { FactoryBot.attributes_for(:user) }

    context 'exsist a user' do
      before do
        post '/api/v1/auth', params: { user: user }
      end

      it 'success authenticate' do
        post '/api/v1/auth/sign_in', params: {
          email: user[:email],
          password: user[:password]
        }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
        expect(response.headers.keys).to \
          include('access-token', 'uid', 'client', 'expiry', 'token-type')
      end
    end
  end

  describe 'logout' do
    context 'as an authenticated user' do
      let!(:user) { FactoryBot.attributes_for(:user) }
      let!(:auth_params) {
        post '/api/v1/auth', params: { user: user }
        get_auth_params_from_login_response_headers(response)
      }

      it 'success logout and APIs require authentication result in a 401 error' do
        aggregate_failures do
          delete '/api/v1/auth/sign_out', headers: auth_params
          expect(response).to have_http_status(:success)

          get '/api/v1/mypage', headers: auth_params
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  #FIXME:helper methodにする
  def get_auth_params_from_login_response_headers(response)
    {
      'access-token': response.headers['access-token'],
      client: response.headers['client'],
      uid: response.headers['uid']
    }
  end
end
