require 'json'

RSpec.describe 'Api::V1::Sessions', type: :request do
  #FIXME: 変数と前処理を毎回しなくてもいいように
  let(:user) { FactoryBot.attributes_for(:user) }
  before do
    @auth_params = sign_up(user)
  end

  describe 'login' do
    context 'not authenticated' do
      context 'exist a user' do
        it 'successful API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }
          expect(response).to have_http_status(:success)
          expect(response.headers.keys).to \
            include('access-token', 'uid', 'client', 'expiry', 'token-type')
          expect(response.body.strip).to eq ''
        end
      end

      context 'not exist a user' do
        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: 'not_exist_user@example.com',
            password: 'password'
          }
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as an authenticated user' do
      context 'authenticated user and user trying to sign in are same' do
        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }, headers: @auth_params
          expect(response).to have_http_status(401)
        end
      end

      context 'authenticated user and user trying to sign in are different' do
        let(:auth_params) { sign_in(FactoryBot.attributes_for(:user, :registed_user1)) }

        it 'failed API call and authentication' do
          post '/api/v1/auth/sign_in', params: {
            email: user[:email],
            password: user[:password]
          }, headers: auth_params
          expect(response).to have_http_status(401)
        end
      end

      context 'post_params is nil' do
        it 'failed API call' do
          post '/api/v1/auth/sign_in', headers: @auth_params
          expect(response).to have_http_status(401)
        end
      end

      context 'only unnecessary params exist in request body' do
        let(:post_params) { generate_unnecessary_params }

        it "failed API call and doesn't create a user" do
          aggregate_failures do
            post '/api/v1/auth/sign_in', headers: @auth_params, params: post_params
            expect(response).to have_http_status(401)
          end
        end
      end

      context 'request body include unnecessary params' do
        let(:post_params) { {
          email: user[:email],
          password: user[:password]
        }.merge(generate_unnecessary_params) }

        before do
          delete '/api/v1/auth/sign_out', headers: @auth_params
        end

        it 'successful API call and create a user' do
          aggregate_failures do
            post '/api/v1/auth/sign_in', headers: @auth_params, params: post_params
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end

  describe 'logout' do
    context 'as an authenticated user' do
      it 'API call succeeds and logout succeeds' do
        delete '/api/v1/auth/sign_out', headers: @auth_params
        expect(response).to have_http_status(:success)
      end

      it 'after logout, calling an API that requires authentication results in an error' do
        delete '/api/v1/auth/sign_out', headers: @auth_params

        get '/api/v1/mypage', headers: @auth_params
        expect(response).to have_http_status(401)
      end
    end

    context 'header is null' do
      it 'failed API call' do
        delete '/api/v1/auth/sign_out'
        expect(response).to have_http_status(404)
      end
    end
  end
end
