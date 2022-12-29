require "rails_helper"

RSpec.describe PlanPolicy, type: :policy do
  describe 'scope' do
    let(:scope) { Pundit.policy_scope!(user, Plan) }

    context 'user.rank is premium' do
      let(:user) { User.new(rank: 'premium') }

      it 'plan.only include nil/premium/normal' do
        onlys = scope.map { |plan| plan['only'] }
        expect(onlys).to include(nil, 'premium', 'normal')
      end
    end

    context 'user.rank is normal' do
      let(:user) { User.new(rank: 'normal') }

      it 'plan.only include nil/normal' do
        onlys = scope.map { |plan| plan['only'] }
        expect(onlys).to include(nil, 'normal')
        expect(onlys).to_not include('premium')
      end
    end

    context 'user is nil' do
      let(:user) { nil }

      it 'plan.only include nil' do
        onlys = scope.map { |plan| plan['only'] }
        expect(onlys).to include(nil)
        expect(onlys).to_not include('normal', 'premium')
      end
    end
  end
end
