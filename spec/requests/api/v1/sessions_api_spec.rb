require 'json'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:user) { FactoryBot.attributes_for(:user) }
  let(:auth_params) { sign_up(user) }

  describe 'login' do
    let(:post_params) { {
      email: user[:email],
      password: user[:password]
    } }

    context 'when non-authenticated' do
      context 'when exist a user' do
        before do
          sign_up(user)
        end

        context 'when request body include email and password only' do
          it 'API call and authentication succeeds' do
            post '/api/v1/auth/sign_in', params: post_params
            expect(response).to have_http_status(:success)
            expect(response.headers.keys).to \
              include('access-token', 'uid', 'client', 'expiry', 'token-type')
            expect(response.body.strip).to_not eq ''
          end
        end

        context 'when request body include unnecessary params' do
          it 'API call successful' do
            aggregate_failures do
              post '/api/v1/auth/sign_in', params: post_params.merge(generate_unnecessary_params)
              expect(response).to have_http_status(:success)
            end
          end
        end
      end

      context 'when not exist a user' do
        it 'API call and authentication failed' do
          post '/api/v1/auth/sign_in', params: {
            email: 'not_exist_user@example.com',
            password: 'password'
          }
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'when user is authenticated' do
      context 'when authenticated user and user trying to sign in are same' do
        it 'API call failed' do
          post '/api/v1/auth/sign_in', params: post_params, headers: auth_params
          expect(response).to have_http_status(401)
        end
      end

      context 'when authenticated user and user trying to sign in are different' do
        let(:auth_params_user1) { sign_in(FactoryBot.attributes_for(:user, :registed_user1)) }

        it 'API call failed' do
          aggregate_failures do
            post '/api/v1/auth/sign_in', params: {
              email: user[:email],
              password: user[:password]
            }, headers: auth_params_user1
            expect(response).to have_http_status(401)

            res_body = JSON.parse(response.body)
            expect(res_body['message']).to_not eq nil
          end
        end
      end
    end

    context 'when post_params is nil' do
      it 'API call failed' do
        aggregate_failures do
          post '/api/v1/auth/sign_in'
          expect(response).to have_http_status(401)

          res_body = JSON.parse(response.body)
          expect(res_body['message']).to_not eq nil
        end
      end
    end

    context 'when only unnecessary params exist in request body' do
      it 'API call failed' do
        aggregate_failures do
          post '/api/v1/auth/sign_in', params: generate_unnecessary_params
          expect(response).to have_http_status(401)

          res_body = JSON.parse(response.body)
          expect(res_body['message']).to_not eq nil
        end
      end
    end
  end

  describe 'logout' do
    context 'when user is authenticated' do
      it 'API call succeeds and logout succeeds' do
        delete '/api/v1/auth/sign_out', headers: auth_params
        expect(response).to have_http_status(:success)
      end

      it 'after logout, calling an API that requires authentication results in an error' do
        delete '/api/v1/auth/sign_out', headers: auth_params

        get '/api/v1/mypage', headers: auth_params
        expect(response).to have_http_status(401)
      end
    end

    context 'when header is null' do
      it 'API call failed' do
        delete '/api/v1/auth/sign_out'
        res_body = JSON.parse(response.body)

        aggregate_failures do
          expect(response).to have_http_status(404)
          expect(res_body['message']).to_not eq nil
        end
      end
    end
  end
end
