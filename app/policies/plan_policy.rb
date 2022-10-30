class PlanPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.where(only: nil) unless user

      if user.rank == 'premium'
        scope.all
      elsif user.rank == 'normal'
        scope.where(only: [nil, 'normal'])
      end
    end
  end
end
