RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'signup' do
    context 'when valid user' do
      let(:user) { FactoryBot.attributes_for(:user) }

      it 'API call successful and create a user' do
        aggregate_failures do
          expect { post '/api/v1/auth', params: user }.to change(User, :count).by(1)
          expect(response).to have_http_status(:success)
          expect(response.headers.keys).to \
            include('access-token', 'uid', 'client', 'expiry', 'token-type')
          expect(response.body.strip).to eq ''
        end
      end
    end

    context 'when invalid user' do
      let(:user) { FactoryBot.attributes_for(:user, :invalid) }

      it 'API call failed and not create a user' do
        aggregate_failures do
          expect { post '/api/v1/auth', params: user }.to_not change(User, :count)
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status(422)
          expect(res_body['message']).to_not eq nil
        end
      end
    end

    context 'when already registered user' do
      let(:user) { FactoryBot.attributes_for(:user) }
      before do
        post '/api/v1/auth', params: user
      end

      it 'API call failed and not create a user' do
        aggregate_failures do
          expect { post '/api/v1/auth', params: user }.to_not change(User, :count)
          # emailのバリデーションに引っかかるので422
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status(422)
          expect(res_body['message']).to_not eq nil
        end
      end
    end

    context 'when auth_params in request header' do
      let(:registed_user2) { FactoryBot.attributes_for(:user, :registed_user2) }
      let(:auth_params) { sign_in(registed_user2) }
      let(:creating_user) { FactoryBot.attributes_for(:user) }

      it 'API call failed and not create a user' do
        expect {
          post '/api/v1/auth', params: creating_user, headers: auth_params
        }.to_not change(User, :count)
        expect(response).to have_http_status(403)

        res_body = JSON.parse(response.body)
        expect(res_body['message']).to_not eq nil
      end
    end

    context 'when request body include unnecessary params' do
      let(:params) { FactoryBot.attributes_for(:user).merge(generate_unnecessary_params) }

      it 'API call successful and create a user' do
        aggregate_failures do
          expect { post '/api/v1/auth', params: params }.to change(User, :count).by(1)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when only unnecessary params exist in request body' do
      let(:params) { generate_unnecessary_params }

      it "API call failed and doesn't create a user" do
        aggregate_failures do
          expect { post '/api/v1/auth', params: params }.to_not change(User, :count)
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status(422)
          expect(res_body['message']).to_not eq nil
        end
      end
    end

    context 'when post_params is nil' do
      it "API call failed and doesn't create a user" do
        aggregate_failures do
          expect { post '/api/v1/auth' }.to_not change(User, :count)
          res_body = JSON.parse(response.body)

          expect(response).to have_http_status(422)
          expect(res_body['message']).to_not eq nil
        end
      end
    end
  end
end
