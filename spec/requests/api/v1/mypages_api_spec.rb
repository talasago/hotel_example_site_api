require 'json'

RSpec.describe 'Api::V1::Mypages', type: :request do
  let!(:user) { FactoryBot.attributes_for(:user) }

  describe 'DELETE /mypage' do
    context 'when user is authenticated' do
      before do
        @auth_params = sign_up(user)
      end

      it 'API call successful and delete a user. Then, an error when calling API that require authentication' do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage', headers: @auth_params
          }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:success)

          get '/api/v1/mypage', headers: @auth_params
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'when non-authenticated' do
      it 'API call failed and not delete a user' do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage'
          }.to_not change(User, :count)
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'when only unnecessary params exist in request body' do
      let(:params) { generate_unnecessary_params }
      before do
        @auth_params = sign_up(user)
      end

      it "API call failed and doesn't create a user" do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage', headers: @auth_params, params: params
          }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'users.id between 1 and 4' do
      context 'users.id = 1' do
        let(:auth_params) { sign_in(FactoryBot.attributes_for(:user, :registed_user1)) }

        it 'API call failed and user is not deleted' do
          aggregate_failures do
            expect {
              delete '/api/v1/mypage', headers: auth_params
            }.to_not change(User, :count)
            expect(response).to have_http_status(403)

            res_body = JSON.parse(response.body)
            expect(res_body['message']).to_not eq nil
          end
        end
      end

      context 'users.id = 4' do
        let(:auth_params) { sign_in(FactoryBot.attributes_for(:user, :registed_user4)) }

        it 'API call failed and user is not deleted' do
          aggregate_failures do
            expect {
              delete '/api/v1/mypage', headers: auth_params
            }.to_not change(User, :count)
            expect(response).to have_http_status(403)

            res_body = JSON.parse(response.body)
            expect(res_body['message']).to_not eq nil
          end
        end
      end
    end
  end

  describe 'GET /mypage' do
    context 'when user is authenticated' do
      let!(:expect_user) do
        u = user.deep_dup
        u.delete(:password)
        u
      end

      before do
        @auth_params = sign_up(user)
      end

      it 'API call successful and include user info and include specified key' do
        get '/api/v1/mypage', headers: @auth_params
        res_body = JSON.parse(response.body, symbolize_names: true)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body).to eq expect_user
        end
      end
    end

    context 'when non-authenticated' do
      it 'API call failed' do
        get '/api/v1/mypage'
        expect(response).to have_http_status(401)
      end
    end

    context 'when only unnecessary params exist in request body' do
      let(:params) { generate_unnecessary_params }
      before do
        @auth_params = sign_up(user)
      end

      it "API call failed and doesn't create a user" do
        aggregate_failures do
          get '/api/v1/mypage', headers: @auth_params, params: params
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
