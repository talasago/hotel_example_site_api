class Api::V1::PlansController < ApplicationController
  def index
    render json: { plans: policy_scope(Plan) }
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

    plan = matched_plan.as_json(except: [:id, :room_type_id])
    user_name = { user_name: current_api_v1_user&.username }
    room_type = { room_type: matched_plan.room_type.as_json(except: [:id, :room_category_name]) }

    render json: plan.merge(user_name, room_type)
  end

  # TODO:permitみたいなの必要かも
end
