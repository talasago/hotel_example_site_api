require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Mypages', type: :request do
  describe 'DELETE /mypage' do
    # 遅延評価だとexpect内でUserが作成されてすぐ削除される。
    # Userの件数がexpect内で+1,-1となり件数が0となってしまう。その為遅延評価は使用しない。
    let!(:auth_params) {
      post '/api/v1/auth', params: { user: FactoryBot.attributes_for(:user) }
      get_auth_params_from_login_response_headers(response)
    }

    context 'as an authenticated user' do
      it 'delete a user' do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage', headers: auth_params
          }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  def get_auth_params_from_login_response_headers(response)
    {
      'access-token': response.headers['access-token'],
      client: response.headers['client'],
      uid: response.headers['uid']
    }
  end
end
