class Api::V1::ReservesController < ApplicationController
  def provisional_regist
    reserve = Reserve.new(provisional_reserve_params)
    render status: 400 and return unless reserve.valid?

    if policy_scope(Plan.where(id: provisional_reserve_params[:plan_id])).empty?
      raise HotelExampleSiteApiExceptions::UnauthorizedError
        .new('Only users of the membership rank specified in the plan can access the system.')
    end

    reserve.save

    render json: generate_response_body(reserve)
  end

  def definitive_regist
    begin
      reserve = Reserve.find_by!(id: definitive_reserve_params[:reserve_id])
    rescue ActiveRecord::RecordNotFound
      render status: 404 and return
    end

    if reserve.is_definitive_regist || # すでに本登録済みならばエラー
       DateTime.now > reserve.session_expires_at.to_datetime # 有効時間が過ぎていればエラー
      render status: 409 and return
    end
    render status: 400 and return unless definitive_reserve_params[:session_token] == reserve.session_token

    update_reserve(reserve)
    render :json
  end

  private

  def generate_response_body(reserve)
    res = reserve.as_json(except: ['plan_id', 'session_expires_at', 'is_definitive_regist'])
    res['plan_name'] = reserve.plan.as_json(only: 'name')['name']
    res['reserve_id'] = res.delete('id')
    res['start_date'] = res.delete('date').gsub(/-/, '/')
    res['end_date'] = reserve.end_date.strftime('%Y/%m/%d')
    res
  end

  def update_reserve(reserve)
    reserve.is_definitive_regist = true
    reserve.session_token = nil
    reserve.session_expires_at = nil

    reserve.save
  end

  def provisional_reserve_params
    params
      .permit(:plan_id, :total_bill, :term, :head_count, :breakfast, :early_check_in,
              :sightseeing, :username, :contact, :tel, :email, :comment)
      .merge(date: params[:date]&.to_date,
             session_token: SecureRandom.base64,
             session_expires_at: DateTime.now + Rational(5, 24 * 60), # 5分後
             is_definitive_regist: false)
  end

  def definitive_reserve_params
    params.permit(:reserve_id, :session_token)
  end
end
