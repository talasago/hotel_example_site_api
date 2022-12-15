require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    context 'contact is no' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)
      end
    end

    context 'concact is tel' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_tel) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)
      end
    end

    context 'contact is email' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_email) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
