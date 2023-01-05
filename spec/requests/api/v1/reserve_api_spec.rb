require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    shared_examples 'expectation POST /reserve' do
      it 'successful API call and create a "reserve" and include specified key' do
        aggregate_failures do
          expect {
            post '/api/v1/reserve', params: post_params
          }.to change(Reserve, :count).by(1)
          expect(response).to have_http_status(:success)
          res_body = JSON.parse(response.body)

          expect(res_body.keys)
            .to contain_exactly('reserve_id', 'total_bill', 'plan_name', 'start_date', 'end_date', 'term', 'head_count',
                                'breakfast', 'early_check_in', 'sightseeing', 'username', 'contact', 'tel', 'email',
                                'comment', 'session_token')
          expect(res_body['start_date']).to match(/[0-9]{4}(\/[0-9]{2}){2}/) # YYYY/MM/DD形式
          expect(res_body['end_date']).to match(/[0-9]{4}(\/[0-9]{2}){2}/) # YYYY/MM/DD形式
          expect(Reserve.find(res_body['reserve_id']).is_definitive_regist).to eq false
        end
      end
    end

    context 'contact is "no"' do
      let(:post_params) { FactoryBot.attributes_for(:reserve) }
      include_examples 'expectation POST /reserve'
    end

    context 'concact is tel' do
      let(:post_params) { FactoryBot.attributes_for(:reserve, :with_tel) }
      include_examples 'expectation POST /reserve'
    end

    context 'contact is email' do
      let(:post_params) { FactoryBot.attributes_for(:reserve, :with_email) }
      include_examples 'expectation POST /reserve'
    end
  end

  describe 'POST /reserve/:reserve_id' do
    before do
      post '/api/v1/reserve', params: { **FactoryBot.attributes_for(:reserve, :with_email) }
      @res_body_provisional_regist = JSON.parse(response.body)
    end
    let(:reserve_id) { @res_body_provisional_regist['reserve_id'] }

    context 'token does match' do
      let(:session_token) { @res_body_provisional_regist['session_token'] }
      it 'successful API call and complete definitive registation' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(:success)

          reserve = Reserve.find(reserve_id)
          expect(reserve.is_definitive_regist).to eq true
          expect(reserve.session_token).to eq nil
          expect(reserve.session_expires_at).to eq nil
        end
      end
    end

    context "token doesn't match" do
      let(:invalid_session_token) { 'hogehogehoge' }
      it 'failed API call and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: invalid_session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)

          reserve = Reserve.find(reserve_id)
          expect(reserve.is_definitive_regist).to eq false
          expect(reserve.session_token).to_not eq nil
          expect(reserve.session_expires_at).to_not eq nil
        end
      end
    end

    context 'token is nil' do
      it 'failed API call and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}"
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)

          reserve = Reserve.find(reserve_id)
          expect(reserve.is_definitive_regist).to eq false
          expect(reserve.session_token).to_not eq nil
          expect(reserve.session_expires_at).to_not eq nil
        end
      end
    end

    context 'not exist reserve_id' do
      before do
        Reserve.find(reserve_id).delete
      end
      let(:session_token) { @res_body_provisional_regist['session_token'] }

      it 'failed API call and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
