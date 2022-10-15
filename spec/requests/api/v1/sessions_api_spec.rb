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
end
