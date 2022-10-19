require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'signup' do
    context 'regist success' do
      let(:user) { FactoryBot.attributes_for(:user) }

      it 'Create a user' do
        expect {
          post '/api/v1/auth', params: { user: user }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
        expect(response.headers.keys).to \
          include('access-token', 'uid', 'client', 'expiry', 'token-type')
      end
    end

    context 'error due to invalid user' do
      let(:user) { FactoryBot.attributes_for(:user, :invalid) }
      it 'not create a user' do
        expect {
          post '/api/v1/auth', params: { user: user }
        }.to_not change(User, :count)
        expect(response).to_not be_successful
      end
    end
  end
end
