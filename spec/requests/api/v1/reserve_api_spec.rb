RSpec.describe 'Api::V1::Reserves', type: :request do
  describe 'POST /reserve' do
    context 'when non-authenticated' do
      shared_examples 'expectation when non-authenticated and response successed' do
        it 'API call successful and add provisional registration and include specified key' do
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

      context 'when plan.only is null' do
        # NOTE: 各連絡情報のありなしでレスポンスボディの内容が変わることは無いので、
        # ここ以外で"contact is XXX"の分岐でテストは実施しない
        context 'contact is "no"' do
          let(:post_params) { FactoryBot.attributes_for(:reserve) }
          include_examples 'expectation when non-authenticated and response successed'
        end

        context 'when concact is tel' do
          let(:post_params) { FactoryBot.attributes_for(:reserve, :with_tel) }
          include_examples 'expectation when non-authenticated and response successed'
        end

        context 'when contact is email' do
          let(:post_params) { FactoryBot.attributes_for(:reserve, :with_email) }
          include_examples 'expectation when non-authenticated and response successed'
        end
      end

      # NOTE: プランごとのuser.rank判定は、policy_specでテスト済みなので、
      # 'plan.only is normal'のテストは実施しない
      context 'when plan.only is premium' do
        let(:post_params) { FactoryBot.attributes_for(:reserve, :with_only_premium) }

        it "API call failed and doesn't add provisional registration" do
          aggregate_failures do
            expect {
              post '/api/v1/reserve', params: post_params
            }.to_not change(Reserve, :count)
            expect(response).to have_http_status(401)
          end
        end
      end

      # NOTE:認証されているされていないで期待値が変わることはない想定なので、
      # 認証されている場合のテストは実施せず、非認証の場合のみテストする
      context 'when request body include unnecessary params' do
        let(:post_params) {
          FactoryBot.attributes_for(:reserve, :with_email).merge(generate_unnecessary_params)
        }
        include_examples 'expectation when non-authenticated and response successed'
      end

      # NOTE:認証されているされていないで期待値が変わることはない想定なので、
      # 認証されている場合のテストは実施せず、非認証の場合のみテストする
      context 'when only unnecessary params exist in request body' do
        let(:post_params) { generate_unnecessary_params }

        it "API call failed and doesn't add provisional registration" do
          aggregate_failures do
            expect {
              post '/api/v1/reserve', params: post_params
            }.to_not change(Reserve, :count)
            expect(response).to have_http_status(400)
          end
        end
      end

      # NOTE:認証されているされていないで期待値が変わることはない想定なので、
      # 認証されている場合のテストは実施せず、非認証の場合のみテストする
      context 'when post_params is nil' do
        it "API call failed and doesn't add provisional registration" do
          aggregate_failures do
            expect {
              post '/api/v1/reserve'
            }.to_not change(Reserve, :count)
            expect(response).to have_http_status(400)
          end
        end
      end
    end

    context 'when user is authenticated' do
      # NOTE: プランごとのuser.rank判定は、policy_specでテスト済みなので、
      # 最低限のuser.rankとplan.onlyの組み合わせしかテストを実施しない
      context 'when user.rank is premium' do
        context 'when plan.only is premium' do
          let(:auth_params) { sign_in(**FactoryBot.attributes_for(:user, :registed_user1)) }
          let(:post_params) { FactoryBot.attributes_for(:reserve, :with_only_premium) }

          it 'API call successful' do
            # NOTE: ユーザーのランクに応じてレスポンスボディの内容が変わるわけではないので、
            # レスポンスボディのキーや日付形式などのexpectは割愛
            aggregate_failures do
              expect {
                post '/api/v1/reserve', params: post_params, headers: auth_params
              }.to change(Reserve, :count).by(1)
              expect(response).to have_http_status(:success)
            end
          end
        end
      end

      context 'when user.rank is normal' do
        context 'when plan.only is premium' do
          let(:auth_params) { sign_in(**FactoryBot.attributes_for(:user, :registed_user2)) }
          let(:post_params) { FactoryBot.attributes_for(:reserve, :with_only_premium) }

          it "API call failed and doesn't add provisional registration" do
            aggregate_failures do
              expect {
                post '/api/v1/reserve', params: post_params, headers: auth_params
              }.to_not change(Reserve, :count)
              expect(response).to have_http_status(401)
            end
          end
        end
      end
    end

    context 'when validation error' do
      let(:params) { { plan_id: 0 } }

      it "API call failed and doesn't add provisional registration" do
        aggregate_failures do
          expect {
            post '/api/v1/reserve', params: params
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)
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
    let(:reserve_before_post) { Reserve.find(reserve_id).attributes }
    let(:session_token) { @res_body_provisional_regist['session_token'] }

    context 'when token does match' do
      it 'API call successful and complete definitive registation' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(:success)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end

    context "when token doesn't match" do
      let(:invalid_session_token) { 'hogehogehoge' }

      it 'API call failed and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: invalid_session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end

    context 'when token is nil' do
      it 'API call failed and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}"
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end

    context 'when not exist reserve_id' do
      before do
        Reserve.find(reserve_id).delete
      end
      let(:session_token_after_request) { @res_body_provisional_regist['session_token'] }

      it 'API call failed' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token_after_request }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when already provisional registered(is_definitive_regist is true)' do
      before do
        post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token }
      end

      it 'API call failed and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: { session_token: session_token }
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(409)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end

    context 'when request body include unnecessary params' do
      let(:params) { { session_token: session_token }.merge(generate_unnecessary_params) }

      it 'API call successful and complete definitive registation' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: params
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(:success)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end

    context 'when only unnecessary params exist in request body' do
      it 'API call failed and remain provisional registration' do
        aggregate_failures do
          expect {
            post "/api/v1/reserve/#{reserve_id}", params: generate_unnecessary_params
          }.to_not change(Reserve, :count)
          expect(response).to have_http_status(400)

          reserve_after_request = Reserve.find(reserve_id).attributes
          expect(reserve_after_request).to eq reserve_before_post
        end
      end
    end
  end
end
