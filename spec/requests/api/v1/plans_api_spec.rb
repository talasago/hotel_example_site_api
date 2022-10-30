require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  describe 'as a not authenticated user' do
    it 'Only the record "rank is nil" is included in the response' do
      get '/api/v1/plans'
      res_body = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      puts res_body
      expect(res_body['plans'][0].key?(:rank))
      res_body['plans'].each do |plan|
        expect(plan['rank']).to be nil
      end
    end
  end

  describe 'as an authenticated user' do
    describe 'rank of user is premium' do
      it 'include all rank in response' do
        # TODO:FactoryBot使うかなあ？
        post '/api/v1/auth/sign_in', params: {
          email: 'ichiro@example.com',
          password: 'password'
        }
        auth_params = get_auth_params_from_login_response_headers(response)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        ranks = res_body['plans'].map { |plan| plan['only'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          #TODO: 後でeach文に変える
          expect(ranks).to include(nil, 'premium', 'normal')
        end
      end
    end

    describe 'rank of user is normal' do
      it 'include only rank nil or normal in response' do
        # TODO:FactoryBot使うかなあ？
        post '/api/v1/auth/sign_in', params: {
          email: 'sakura@example.com',
          password: 'pass1234'
        }
        auth_params = get_auth_params_from_login_response_headers(response)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        ranks = res_body['plans'].map { |plan| plan['only'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          #TODO: 後でeach文に変える
          expect(ranks).to include(nil, 'normal')
          expect(ranks).to_not include('premium')
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
