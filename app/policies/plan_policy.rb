class PlanPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.where(member_rank: nil) unless user

      if user.member_rank == 'premium'
        scope.all
      elsif user.member_rank == 'member'
        scope.where(member_rank: [nil, 'member'])
      end
    end
  end
end
