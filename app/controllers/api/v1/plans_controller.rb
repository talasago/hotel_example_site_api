class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: policy_scope(Plan) }
  end
end
