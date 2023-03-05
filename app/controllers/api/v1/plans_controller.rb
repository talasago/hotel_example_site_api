class Api::V1::PlansController < ApplicationController
  def index
    return_plans = search_plans.map do |plan|
      plan.as_json(except: [:id, :room_type_id])
          .merge({ room_category_type_name: plan.room_type&.room_category_type_name })
    end

    render json: { message: 'Get completed.', data: { plans: return_plans } }
  end

  def show
    matched_plan = search_plan

    if matched_plan.nil?
      raise HotelExampleSiteApiExceptions::UnauthorizedError
        .new('Only users of the membership rank specified in the plan can access the system.')
    end

    render json: { message: 'Get completed.', data: build_response_data(matched_plan) }
  end

  private

  def build_response_data(plan)
    {
      plan: plan.as_json(except: [:id, :room_type_id]),
      user: api_v1_user_signed_in? ? build_user_hash : nil,
      room_type: plan
        .room_type.as_json(except: [:id, :room_category_name])
        &.merge({ room_category_type_name: plan.room_type.room_category_type_name })
    }
  end

  def build_user_hash
    {
      username: current_api_v1_user.username,
      tel: current_api_v1_user.tel,
      email: current_api_v1_user.email
    }
  end

  def plan_params
    params.permit(:id)
  end

  def search_plan
    policy_scope(Plan.where(plan_params)).select(
      '"plans".id AS plan_id,
      name AS plan_name,
      room_bill,
      min_head_count,
      max_head_count,
      min_term,
      max_term,
      room_type_id'
    ).first
  end

  def search_plans
    policy_scope(Plan.includes(:room_type)).select(
      '"plans".id AS plan_id,
      name AS plan_name,
      room_bill,
      min_head_count,
      "plans".only,
      room_type_id'
    ).order(:plan_id)
  end
end
