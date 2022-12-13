require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    it 'regist success' do
      expect {
        post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve) }
      }.to change(Reserve, :count).by(1)
      expect(response).to have_http_status(:success)
    end
  end
end
