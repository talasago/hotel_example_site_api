class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: Plan.where(member_rank: nil) }
  end
end
