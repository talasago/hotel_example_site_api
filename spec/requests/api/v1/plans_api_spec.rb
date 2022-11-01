require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  describe 'as a not authenticated user' do
    it 'Only the record "rank is nil" is included in the response' do
      get '/api/v1/plans'
      res_body = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(res_body['plans'][0].key?(:rank))
      res_body['plans'].each do |plan|
        expect(plan['rank']).to be nil
      end
    end
  end

  describe 'as an authenticated user' do
    describe 'rank of user is premium' do
      let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }

      it 'include all rank in response' do
        auth_params = sign_in(registed_user1)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          res_body['plans'].each do |plan|
            expect(plan['rank']).to eq(nil) | eq('premium') | eq('normal')
          end
        end
      end
    end

    describe 'rank of user is normal' do
      let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

      it 'include only rank nil or normal in response' do
        auth_params = sign_in(registed_user2)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          res_body['plans'].each do |plan|
            expect(plan['rank']).to eq(nil) | eq('normal')
            expect(plan['rank']).to_not eq('premium')
          end
        end
      end
    end
  end
end
