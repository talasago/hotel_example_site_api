require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:user) { FactoryBot.attributes_for(:user) }
  before do
    @auth_params = sign_up(user)
  end

  describe 'login' do
    context 'not authenticated' do
      context 'exist a user' do
        it 'successful API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }
          expect(response).to have_http_status(:success)
          expect(response.headers.keys).to \
            include('access-token', 'uid', 'client', 'expiry', 'token-type')
          expect(response.body.strip).to eq ''
        end
      end

      context 'not exist a user' do
        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: 'not_exist_user@example.com',
            password: 'password'
          }
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as an authenticated user' do
      context 'authenticated user and user trying to sign in are same' do
        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }, headers: @auth_params
          expect(response).to have_http_status(401)
        end
      end

      context 'authenticated user and user trying to sign in are different' do
        let(:auth_params) { sign_in(FactoryBot.attributes_for(:user, :registed_user1)) }

        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }, headers: auth_params
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe 'logout' do
    context 'as an authenticated user' do
      it 'API call succeeds and logout succeeds' do
        delete '/api/v1/auth/sign_out', headers: @auth_params
        expect(response).to have_http_status(:success)
      end

      it 'after logout, calling an API that requires authentication results in an error' do
        delete '/api/v1/auth/sign_out', headers: @auth_params

        get '/api/v1/mypage', headers: @auth_params
        expect(response).to have_http_status(401)
      end
    end
  end
end
