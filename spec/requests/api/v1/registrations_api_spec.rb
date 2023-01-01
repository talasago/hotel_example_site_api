require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'signup' do
    context 'valid user' do
      let(:user) { FactoryBot.attributes_for(:user) }

      it 'successful API call and create a user' do
        expect {
          post '/api/v1/auth', params: user
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response.headers.keys).to \
          include('access-token', 'uid', 'client', 'expiry', 'token-type')
      end
    end

    context 'invalid user' do
      let(:user) { FactoryBot.attributes_for(:user, :invalid) }
      it 'failed API call and not create a user' do
        expect {
          post '/api/v1/auth', params: user
        }.to_not change(User, :count)
        expect(response).to have_http_status(422)
      end
    end
  end
end
