require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }
  let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

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
              plan_id: 0,
              plan_name: 'お得な特典付きプラン',
              room_bill: 7000,
              min_head_count: 1,
              max_head_count: 9,
              min_term: 1,
              max_term: 9,
              user_name: nil,
              room_category_type_name: 'スタンダードツイン',
              room_type_name: 'ツイン',
              min_capacity: 1,
              max_capacity: 2,
              room_size: 18,
              facilities: ['ユニット式バス・トイレ', '独立洗面台']
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
        before do
          @auth_params = sign_in(registed_user1)
        end

        it 'success get "plans.only is premium"' do
          get '/api/v1/plans/1', headers: @auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan_id: 1,
                plan_name: 'プレミアムプラン',
                room_bill: 10_000,
                min_head_count: 2,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '山田一郎',
                room_category_type_name: 'プレミアムツイン',
                room_type_name: 'ツイン',
                min_capacity: 1,
                max_capacity: 3,
                room_size: 24,
                facilities: ['セパレート式バス・トイレ', '独立洗面台']
              }
            )
          end
        end

        it 'success get "plans.only is member"' do
          get '/api/v1/plans/3', headers: @auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan_id: 3,
                plan_name: 'お得なプラン',
                room_bill: 6000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '山田一郎',
                room_category_type_name: nil,
                room_type_name: nil,
                min_capacity: nil,
                max_capacity: nil,
                room_size: nil,
                facilities: nil
              }
            )
          end
        end

        it 'success get "plans.only is null"' do
          get '/api/v1/plans/0', headers: @auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan_id: 0,
                plan_name: 'お得な特典付きプラン',
                room_bill: 7000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '山田一郎',
                room_category_type_name: 'スタンダードツイン',
                room_type_name: 'ツイン',
                min_capacity: 1,
                max_capacity: 2,
                room_size: 18,
                facilities: ['ユニット式バス・トイレ', '独立洗面台']
              }
            )
          end
        end
      end

      describe 'Only Premium Plan can be reserved' do
        before do
          @auth_params = sign_in(registed_user2)
        end

        it 'success get "plans.only is null"' do
          get '/api/v1/plans/0', headers: @auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan_id: 0,
                plan_name: 'お得な特典付きプラン',
                room_bill: 7000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '松本さくら',
                room_category_type_name: 'スタンダードツイン',
                room_type_name: 'ツイン',
                min_capacity: 1,
                max_capacity: 2,
                room_size: 18,
                facilities: ['ユニット式バス・トイレ', '独立洗面台']
              }
            )
          end
        end

        it 'dissuccess get "plans.only is premium"' do
          get '/api/v1/plans/1', headers: @auth_params
          expect(response).to have_http_status(401)
        end

        it 'success get "plans.only is member"' do
          get '/api/v1/plans/3', headers: @auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan_id: 3,
                plan_name: 'お得なプラン',
                room_bill: 6000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9,
                user_name: '松本さくら',
                room_category_type_name: nil,
                room_type_name: nil,
                min_capacity: nil,
                max_capacity: nil,
                room_size: nil,
                facilities: nil
              }
            )
          end
        end
      end
    end
  end
end
