require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  describe 'as a not authenticated user' do
    it 'Only the record "member_rank is nil" is included in the response' do
      get '/api/v1/plans'
      res_body = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(res_body['plans'][0].key?(:member_rank))
      res_body['plans'].each do |plan|
        expect(plan['member_rank']).to be nil
      end
    end
  end

  describe 'as an authenticated user' do
    describe 'member_rank of user is premium' do
      it 'include all member_rank in response' do
        # TODO:FactoryBot使うかなあ？
        post '/api/v1/auth/sign_in', params: {
          email: 'ichiro@example.com',
          password: 'password'
        }
        auth_params = get_auth_params_from_login_response_headers(response)

        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        member_ranks = res_body['plans'].map { |plan| plan['member_rank'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(member_ranks).to include(nil, 'premium', 'member')
        end
      end
    end

    it 'member_rank = member'
  end


  def get_auth_params_from_login_response_headers(response)
    {
      'access-token': response.headers['access-token'],
      client: response.headers['client'],
      uid: response.headers['uid']
    }
  end
end
