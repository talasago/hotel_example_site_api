require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }

  describe '/plans GET' do
    describe 'not authenticated' do
      it 'Only the record "only is nil" is included in the response' do
        get '/api/v1/plans'
        res_body = JSON.parse(response.body)
        onlys = res_body['plans'].map { |plan| plan['only'] }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body['plans'][0].key?(:only))
          expect(onlys).to include(nil)
          expect(onlys).to_not include('member', 'premium')
        end
      end
    end

    describe 'as an authenticated user' do
      describe 'only of user is premium' do

        it 'include all only in response' do
          auth_params = sign_in(registed_user1)

          get '/api/v1/plans', headers: auth_params
          res_body = JSON.parse(response.body)
          onlys = res_body['plans'].map { |plan| plan['only'] }

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(onlys).to include(nil, 'premium', 'normal')
          end
        end
      end

      describe 'only of user is normal' do
        let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

        it 'include only only nil or normal in response' do
          auth_params = sign_in(registed_user2)

          get '/api/v1/plans', headers: auth_params
          res_body = JSON.parse(response.body)
          onlys = res_body['plans'].map { |plan| plan['only'] }

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(onlys).to include(nil, 'normal')
            expect(onlys).to_not include('premium')
          end
        end
      end
    end
  end

  describe '/plans/:id' do
    describe 'not authenticated' do
      it 'success get "plans.only is null"' do
        get '/api/v1/plans/0'
        res_body = JSON.parse(response.body, symbolize_names: true)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body).to eq(
            {
              id: 0,
              plan_name: 'お得な特典付きプラン',
              room_bill: 7000,
              min_head_count: 1,
              max_head_count: 9,
              min_term: 1,
              max_term: 9,
              user_name: nil
            }
          )
        end
      end
      it 'dissuccess get "plans.only is premium"' do
        get '/api/v1/plans/1'

        expect(response).to have_http_status(401)
      end
      it 'dissuccess get "plans.only is member"' do
        get '/api/v1/plans/3'

        expect(response).to have_http_status(401)
      end
    end

    describe 'as an authenticated user' do
      describe 'users.rank is premium' do
        it 'success get "plans.only is premium"' do
          auth_params = sign_in(registed_user1)

          get '/api/v1/plans/1', headers: auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                id: 1,
                plan_name: 'プレミアムプラン',
                room_bill: 10_000,
                min_head_count: 2,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '山田一郎'
              }
            )
          end
        end
        it 'success get "plans.only is member"'
      end

      describe 'Only Premium Plan can be reserved' do
        it 'success get "plans.only is null"'
        it 'dissuccess get "plans.only is premium"'
        it 'success get "plans.only is member"'
      end
    end
  end
end
