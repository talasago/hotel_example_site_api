require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Mypages', type: :request do
  let(:user) { FactoryBot.attributes_for(:user) }

  describe 'DELETE /mypage' do
    context 'as an authenticated user' do
      it 'delete a user' do
        auth_params = sign_up(user)
        aggregate_failures do
          expect {
            delete '/api/v1/mypage', headers: auth_params
          }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'as an unautorized user' do
      it 'not delete a user and result in a 401 error' do
        sign_up(user)
        aggregate_failures do
          expect {
            delete '/api/v1/mypage'
          }.to_not change(User, :count)
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe 'GET /mypage' do
    context 'as an authenticated user' do
      it 'get a user-info' do
        auth_params = sign_up(user)
        get '/api/v1/mypage', headers: auth_params
        res_body = JSON.parse(response.body)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body['user'].keys).to \
            include('email', 'username', 'rank', 'address', 'tel',
                    'gender', 'birthday', 'notification')
          expect(res_body['user'].keys).to_not \
            include('password', 'id', 'provider', 'tokens')
          expect(res_body['user']['emeil']).to eq user['email']
        end
      end
    end

    context 'as an unautorized user' do
      it 'get a user-info' do
        sign_up(user)
        get '/api/v1/mypage'
        expect(response).to have_http_status(401)
      end
    end
  end
end
