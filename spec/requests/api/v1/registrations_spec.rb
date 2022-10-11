require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /signup' do
    let(:user) { FactoryBot.attributes_for(:user) }

    it 'responds successfully' do
      expect {
        post '/api/v1/signup', params: {
          user: user
        }
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:success)
    end
  end
end
