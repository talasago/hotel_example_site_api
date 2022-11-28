require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:user) { FactoryBot.attributes_for(:user) }

  describe 'login' do
    context 'exsist a user' do
      before do
        sign_up(user)
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

    context 'not exist a user' do
      it 'error login' do
        post '/api/v1/auth/sign_in', params: {
          email: 'not_exist_user@example.com',
          password: 'password'
        }
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'logout' do
    context 'as an authenticated user' do
      # FIXME:なんか成功なのに401って不安になる書き方。aggregate_failures要らなさそう。
      it 'success logout and APIs require authentication result in a 401 error' do
        auth_params = sign_up(user)
        aggregate_failures do
          delete '/api/v1/auth/sign_out', headers: auth_params
          expect(response).to have_http_status(:success)

          get '/api/v1/mypage', headers: auth_params
          expect(response).to have_http_status(401)
        end
      end
    end
  end
end
