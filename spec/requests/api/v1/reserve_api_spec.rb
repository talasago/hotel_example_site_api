require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    context 'contact is no' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)

        res_body = JSON.parse(response.body)
        expect(res_body.keys)
          .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
            'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment')
        expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
        expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
      end
    end

    context 'concact is tel' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_tel) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)

        res_body = JSON.parse(response.body)
        expect(res_body.keys)
          .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
            'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment')
        expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
        expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
      end
    end

    context 'contact is email' do
      it 'regist success' do
        expect {
          post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_email) }
        }.to change(Reserve, :count).by(1)
        expect(response).to have_http_status(:success)

        res_body = JSON.parse(response.body)
        expect(res_body.keys)
          .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
            'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment')
        expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
        expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
      end
    end
  end
end
