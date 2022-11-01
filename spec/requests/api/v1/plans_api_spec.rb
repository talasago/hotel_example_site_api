require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  describe 'as a not authenticated user' do
    it 'Only the record "only is nil" is included in the response' do
      get '/api/v1/plans'
      res_body = JSON.parse(response.body)
      onlys = res_body['plans'].map { |plan| plan['only'] }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(res_body['plans'][0].key?(:only))
        expect(onlys).to include(nil)
        expect(onlys).to_not include('member', 'premium')
      end
    end
  end

  describe 'as an authenticated user' do
    describe 'only of user is premium' do
      let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }

      it 'include all only in response' do
        auth_params = sign_in(registed_user1)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        onlys = res_body['plans'].map { |plan| plan['only'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(onlys).to include(nil, 'premium', 'normal')
        end
      end
    end

    describe 'only of user is normal' do
      let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

      it 'include only only nil or normal in response' do
        auth_params = sign_in(registed_user2)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        onlys = res_body['plans'].map { |plan| plan['only'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(onlys).to include(nil, 'normal')
          expect(onlys).to_not include('premium')
        end
      end
    end
  end
end
