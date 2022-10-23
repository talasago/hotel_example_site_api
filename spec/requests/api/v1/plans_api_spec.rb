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

  describe 'as an authenticated user and member_rank = premium'
  describe 'as an authenticated user and member_rank = member'
end
