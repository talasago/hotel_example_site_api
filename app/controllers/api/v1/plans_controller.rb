require 'json'

class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: policy_scope(Plan) }
  end

  def show
    plan = Plan.select(
      'name AS plan_name,
      room_bill,
      min_head_count,
      max_head_count,
      min_term,
      max_term'
    ).find(params[:id]).as_json(except: [:id])

    render json: plan
  end

  # TODO:permitみたいなの必要かも
end
