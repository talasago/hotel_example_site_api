require 'json'

RSpec.describe 'Api::V1::Plans', type: :request do
  let(:registed_user1) { FactoryBot.attributes_for(:user, :registed_user1) }
  let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }

  describe 'GET /plans' do
    shared_examples 'expectation GET /plans' do
      it 'API call successful and sort by plan_id asc and include specified keys' do
        get '/api/v1/plans', headers: auth_params
        res_body = JSON.parse(response.body)
        ids = res_body['data']['plans'].map { |plan| plan['plan_id'] }
        plan_id0 = res_body['data']['plans'].find { |plan| plan['plan_id'] == 0 }
        plan_id6 = res_body['data']['plans'].find { |plan| plan['plan_id'] == 6 }

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(ids).to eq ids.sort
          res_body['data']['plans'].each do |plan|
            expect(plan.keys).to match_array([
              'plan_id', 'min_head_count', 'plan_name', 'room_bill', 'room_category_type_name'
            ])
          end
          expect(plan_id0['room_category_type_name']).to eq 'スタンダードツイン'
          expect(plan_id6['room_category_type_name']).to eq '部屋指定なし'
        end
      end
    end

    context 'when non-authenticated' do
      let(:auth_params) { nil }
      include_examples 'expectation GET /plans'
    end

    context 'when user is authenticated' do
      context 'when user.only is premium' do
        let(:auth_params) { sign_in(registed_user1) }
        include_examples 'expectation GET /plans'
      end

      context 'when user.only is normal' do
        let(:auth_params) { sign_in(registed_user2) }
        include_examples 'expectation GET /plans'
      end
    end
  end

  describe 'GET /plan/:id' do
    context 'when non-authenticated' do
      context "when room_type isn't null" do
        it 'API call to acquire data for "plans.only is null" succeeds and include specified response body' do
          get '/api/v1/plan/0' #
          res_body = JSON.parse(response.body, symbolize_names: true)

          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(res_body[:data]).to eq(
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
                user: nil,
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

      it 'API call to acquire data for "plans.only is premium" failed' do
        get '/api/v1/plan/1' # plans.only is premium
        expect(response).to have_http_status(401)
      end

      it 'API call to acquire data for "plans.only is normal" failed' do
        get '/api/v1/plan/3'
        expect(response).to have_http_status(401)
      end
    end

    context 'when user is authenticated' do
      context 'when users.rank is premium' do
        let(:auth_params) { sign_in(registed_user1) }

        it 'API call to acquire data for "plans.only is null" succeeds and include specified response body' do
          get '/api/v1/plan/0', headers: auth_params
          # 認可周りはplan_policy_specでテスト済みなので、詳細なエクスペクテーションは割愛
          expect(response).to have_http_status(:success)
        end

        context "when room_type isn't null" do
          it 'API call to acquire data for "plans.only is premium" succeeds and include specified response body' do
            get '/api/v1/plan/1', headers: auth_params
            res_body = JSON.parse(response.body, symbolize_names: true)

            aggregate_failures do
              expect(response).to have_http_status(:success)
              expect(res_body[:data]).to eq(
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
                  user: {
                    username: '山田一郎',
                    tel: '01234567891',
                    email: 'ichiro@example.com'
                  },
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
        end

        it 'API call to acquire data for "plans.only is normal" succeeds and include specified response body' do
          get '/api/v1/plan/3', headers: auth_params
          # 認可周りはplan_policy_specでテスト済みなので、詳細なエクスペクテーションは割愛
          expect(response).to have_http_status(:success)
        end
      end

      context 'when users.rank is normal' do
        let(:auth_params) { sign_in(registed_user2) }

        it 'API call to acquire data for "plans.only is null" succeeds and include specified response body' do
          get '/api/v1/plan/0', headers: auth_params
          # 認可周りはplan_policy_specでテスト済みなので、詳細なエクスペクテーションは割愛
          expect(response).to have_http_status(:success)
        end

        it 'API call to acquire data for "plans.only is premium" failed' do
          get '/api/v1/plan/1', headers: auth_params
          expect(response).to have_http_status(401)
        end

        context 'when room_type is null' do
          it 'API call to acquire data for "plans.only is normal" succeeds and include specified response body' do
            get '/api/v1/plan/3', headers: auth_params
            res_body = JSON.parse(response.body, symbolize_names: true)

            aggregate_failures do
              expect(response).to have_http_status(:success)
              expect(res_body[:data]).to eq(
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
                  user: {
                    username: '松本さくら',
                    tel: nil,
                    email: 'sakura@example.com'
                  },
                  room_type: {
                    facilities: nil,
                    max_capacity: nil,
                    min_capacity: nil,
                    room_category_type_name: '部屋指定なし',
                    room_size: nil,
                    room_type_name: nil
                  }
                }
              )
            end
          end
        end
      end
    end
  end
end
