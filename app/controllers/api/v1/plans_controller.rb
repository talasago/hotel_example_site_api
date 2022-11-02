require 'json'

class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: policy_scope(Plan) }
  end

  def show
    plan = JSON.parse(
      Plan.find(params[:id]).to_json(
        # 取得する列を指定
        # select()だと:idを返してしまうため
        only: [:name, :room_bill, :min_head_count, :max_head_count, :min_term, :max_term]
      )
    )
    render json: { plan:  }
  end

  # TODO:permitみたいなの必要かも
end
