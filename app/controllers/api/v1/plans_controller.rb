class Api::V1::PlansController < ApplicationController
  def index
    all_plans = policy_scope(Plan.includes(:room_type)).select(
      '"plans".id AS plan_id,
      name AS plan_name,
      room_bill,
      min_head_count,
      "plans".only,
      room_type_id'
    ).order(:plan_id)

    return_plans = all_plans.map do |plan|
      plan.as_json(except: [:id, :room_type_id]).merge(
        { room_category_type_name: plan.room_type&.room_category_type_name }
      )
    end

    render json: { plans: return_plans }
  end

  def show
    #TODO:メソッド化してもいいかも
    matched_plan = policy_scope(Plan.where(plan_params)).select(
      '"plans".id AS plan_id,
      name AS plan_name,
      room_bill,
      min_head_count,
      max_head_count,
      min_term,
      max_term,
      room_type_id'
    ).first

    render status: 401 and return if matched_plan.nil?

    render json: {
      plan: matched_plan.as_json(except: [:id, :room_type_id]),
      user: api_v1_user_signed_in? ? generate_user_hash : nil,
      room_type: matched_plan.room_type.as_json(except: [:id, :room_category_name])&.merge(
        { room_category_type_name: matched_plan.room_type&.room_category_type_name }
      )
    }
  end

  private

  def generate_user_hash
    {
      username: current_api_v1_user.username,
      tel: current_api_v1_user.tel,
      email: current_api_v1_user.email
    }
  end

  def plan_params
    params.permit(:id)
  end
end
