require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    context 'contact is no' do
      it 'regist success' do
        aggregate_failures do
          expect {
            post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve) }
          }.to change(Reserve, :count).by(1)
          expect(response).to have_http_status(:success)

          res_body = JSON.parse(response.body)
          expect(res_body.keys)
            .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
              'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment',
              'session_token')
          expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(Reserve.find(res_body['reserve_id']).is_definitive_regist).to eq false
        end
      end
    end

    context 'concact is tel' do
      it 'regist success' do
        aggregate_failures do
          expect {
            post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_tel) }
          }.to change(Reserve, :count).by(1)
          expect(response).to have_http_status(:success)

          res_body = JSON.parse(response.body)
          expect(res_body.keys)
            .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
              'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment',
              'session_token')
          expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(Reserve.find(res_body['reserve_id']).is_definitive_regist).to eq false
        end
      end
    end

    context 'contact is email' do
      it 'regist success' do
        aggregate_failures do
          expect {
            post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_email) }
          }.to change(Reserve, :count).by(1)
          expect(response).to have_http_status(:success)

          res_body = JSON.parse(response.body)
          expect(res_body.keys)
            .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
              'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email', 'comment',
              'session_token')
          expect(res_body['start_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(res_body['end_date']).to match /[0-9]{4}(\/[0-9]{2}){2}/
          expect(Reserve.find(res_body['reserve_id']).is_definitive_regist).to eq false
        end
      end
    end
  end

  describe 'POST /reserve/:reserve_id' do
    before do
      post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_email) }
      @res_body_provisional_regist = JSON.parse(response.body)
    end

    let(:reserve_id) { @res_body_provisional_regist['reserve_id'] }

    it 'provisional regist success' do
      aggregate_failures do
        expect {
          post "/api/v1/reserve/#{reserve_id}"
        }.to_not change(Reserve, :count)
        expect(response).to have_http_status(:success)

        reserve = Reserve.find(reserve_id)
        expect(reserve.is_definitive_regist).to eq true
        expect(reserve.session_token).to eq nil
        expect(reserve.session_expires_at).to eq nil
      end
    end
  end
end
