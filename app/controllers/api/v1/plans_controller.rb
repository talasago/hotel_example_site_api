require 'json'

class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: policy_scope(Plan) }
  end

  def show
    plan = policy_scope(Plan.where(id: params[:id])).select(
      'name AS plan_name,
      room_bill,
      min_head_count,
      max_head_count,
      min_term,
      max_term'
    ).first.as_json(except: [:id])

    # TODO:Errorのクラスとか作って返した方が良いかも
    if plan.nil?
      render status: 401
      return
    end

    user_name = { user_name: api_v1_user_signed_in? ? current_api_v1_user.username : nil }

    render json: plan.merge(user_name)
  end

  # TODO:permitみたいなの必要かも
end
