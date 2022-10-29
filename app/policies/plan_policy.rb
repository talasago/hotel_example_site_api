class PlanPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user
        if user.member_rank == 'premium'
          scope.all
        end
      else
        scope.where(member_rank: nil)
      end
    end
  end
end
