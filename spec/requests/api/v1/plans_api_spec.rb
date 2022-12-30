require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }
  let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

  describe '/plans GET' do
    shared_examples 'http status is success and sort plan_id and include specified keys' do
      it do
        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        ids = res_body['plans'].map { |plan| plan['plan_id'] }
        plan_id0 = res_body['plans'].find { |plan| plan['plan_id'] == 0 }
        plan_id6 = res_body['plans'].find { |plan| plan['plan_id'] == 6 }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(ids).to eq ids.sort
          res_body['plans'].each do |plan|
            expect(plan.keys).to match_array([
              'plan_id', 'min_head_count', 'only', 'plan_name', 'room_bill', 'room_category_type_name'
            ])
          end
          expect(plan_id0['room_category_type_name']).to eq 'スタンダードツイン'
          expect(plan_id6['room_category_type_name']).to eq nil
        end
      end
    end

    context 'not authenticated' do
      let(:auth_params) { nil }
      include_examples 'http status is success and sort plan_id and include specified keys'
    end

    context 'as an authenticated user' do
      context 'only of user is premium' do
        let(:auth_params) { sign_in(registed_user1) }
        include_examples 'http status is success and sort plan_id and include specified keys'
      end

      context 'only of user is normal' do
        let(:auth_params) { sign_in(registed_user2) }
        include_examples 'http status is success and sort plan_id and include specified keys'
      end
    end
  end

  describe '/plans/:id' do
    shared_examples 'response for plan_id 0 (only is nil)' do |user_name|
      it 'success get "plans.only is null"' do
        get '/api/v1/plans/0', headers: auth_params
        res_body = JSON.parse(response.body, symbolize_names: true)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body).to eq(
            {
              plan: {
                plan_id: 0,
                plan_name: 'お得な特典付きプラン',
                room_bill: 7000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9
              },
              user_name: user_name,
              room_type: {
                room_category_type_name: 'スタンダードツイン',
                room_type_name: 'ツイン',
                min_capacity: 1,
                max_capacity: 2,
                room_size: 18,
                facilities: ['ユニット式バス・トイレ', '独立洗面台']
              }
            }
          )
        end
      end
    end

    shared_examples 'response for plan_id 3 (only is normal)' do |user_name|
      it 'success get "plans.only is normal' do
        get '/api/v1/plans/3', headers: auth_params
        res_body = JSON.parse(response.body, symbolize_names: true)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body).to eq(
            {
              plan: {
                plan_id: 3,
                plan_name: 'お得なプラン',
                room_bill: 6000,
                min_head_count: 1,
                max_head_count: 9,
                min_term: 1,
                max_term: 9
              },
              user_name: user_name,
              room_type: nil
            }
          )
        end
      end
    end

    context 'not authenticated' do
      let(:auth_params) { nil }

      include_examples 'response for plan_id 0 (only is nil)', nil

      it 'dissuccess get "plans.only is premium"' do
        get '/api/v1/plans/1'
        expect(response).to have_http_status(401)
      end

      it 'dissuccess get "plans.only is member"' do
        get '/api/v1/plans/3'
        expect(response).to have_http_status(401)
      end
    end

    context 'as an authenticated user' do
      context 'users.rank is premium' do
        let(:auth_params) { sign_in(registed_user1) }

        include_examples 'response for plan_id 0 (only is nil)', '山田一郎'

        it 'success get "plans.only is premium"' do
          get '/api/v1/plans/1', headers: auth_params
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body).to eq(
              {
                plan: {
                  plan_id: 1,
                  plan_name: 'プレミアムプラン',
                  room_bill: 10_000,
                  min_head_count: 2,
                  max_head_count: 9,
                  min_term: 1,
                  max_term: 9
                },
                user_name: '山田一郎',
                room_type: {
                  room_category_type_name: 'プレミアムツイン',
                  room_type_name: 'ツイン',
                  min_capacity: 1,
                  max_capacity: 3,
                  room_size: 24,
                  facilities: ['セパレート式バス・トイレ', '独立洗面台']
                }
              }
            )
          end
        end

        include_examples 'response for plan_id 3 (only is normal)', '山田一郎'
      end

      context 'Only Premium Plan can be reserved' do
        let(:auth_params) { sign_in(registed_user2) }

        include_examples 'response for plan_id 0 (only is nil)', '松本さくら'

        it 'dissuccess get "plans.only is premium"' do
          get '/api/v1/plans/1', headers: auth_params
          expect(response).to have_http_status(401)
        end

        include_examples 'response for plan_id 3 (only is normal)', '松本さくら'
      end
    end
  end
end
