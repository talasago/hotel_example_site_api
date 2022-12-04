require 'rails_helper'

RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    it 'regist success' do
      expect {
        # HACK:FactoryBotでいいかも。
        post '/api/v1/reserve', params: {
          plan_id: 2,
          total_bill: 13_625,
          date: Date.today.next_occurring(:sunday),
          term: 1,
          head_count: 1,
          breakfast: true,
          early_check_in: true,
          sightseeing: true,
          username: 'テスト太郎',
          contact: 'no',
          comment: 'comment_test'
        }
      }.to change(Reserve, :count).by(1)
      expect(response).to have_http_status(:success)
    end
  end
end
