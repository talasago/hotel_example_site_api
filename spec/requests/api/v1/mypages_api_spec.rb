require 'rails_helper'
require 'json'

RSpec.describe 'Api::V1::Mypages', type: :request do
  let!(:user) { FactoryBot.attributes_for(:user) }

  before do
    @auth_params = sign_up(user)
  end

  describe 'DELETE /mypage' do
    context 'as an authenticated user' do
      it 'successful API call and delete a user and error when calling API that require authentication' do
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

    context 'not authenticated' do
      it 'failed API call and not delete a user' do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage'
          }.to_not change(User, :count)
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'only unnecessary params exist in request body' do
      let(:params) { generate_unnecessary_params }
      it "failed API call and doesn't create a user" do
        aggregate_failures do
          expect {
            delete '/api/v1/mypage', headers: @auth_params, params: params
          }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'GET /mypage' do
    context 'as an authenticated user' do
      let!(:expect_user) do
        u = user.deep_dup
        u.delete(:password)
        u
      end

      it 'successful API call and include user info and include specified key' do
        get '/api/v1/mypage', headers: @auth_params
        res_body = JSON.parse(response.body, symbolize_names: true)

        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(res_body).to eq expect_user
        end
      end
    end

    context 'not authenticatedr' do
      it 'failed API call' do
        get '/api/v1/mypage'
        expect(response).to have_http_status(401)
      end
    end

    context 'only unnecessary params exist in request body' do
      let(:params) { generate_unnecessary_params }
      it "failed API call and doesn't create a user" do
        aggregate_failures do
          get '/api/v1/mypage', headers: @auth_params, params: params
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
