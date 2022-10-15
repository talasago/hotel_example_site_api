require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'DELETE /mypages/:id' do
    # 遅延評価だとexpect内ででUserが作成されてすぐ削除される。
    # Userの件数がexpect内で+1,-1となり件数が0となってしまう。その為遅延評価は使用しない。
    let!(:user) { FactoryBot.create(:user) }

    it 'delete a user' do
      expect {
        delete "/api/v1/mypages/#{user.id}"
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:success)
    end
  end
end
