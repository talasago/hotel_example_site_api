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
    matched_plan = policy_scope(Plan.where(id: params[:id])).select(
      '"plans".id AS plan_id,
      name AS plan_name,
      room_bill,
      min_head_count,
      max_head_count,
      min_term,
      max_term,
      room_type_id'
    ).first

    # TODO:Errorのクラスとか作って返した方が良いかも
    if matched_plan.nil?
      render status: 401
      return
    end

    render json: {
      plan: matched_plan.as_json(except: [:id, :room_type_id]),
      user_name: current_api_v1_user&.username,
      room_type: matched_plan.room_type.as_json(except: [:id, :room_category_name])
    }
  end

  # TODO:permitみたいなの必要かも
end
