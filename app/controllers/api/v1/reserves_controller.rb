class Api::V1::ReservesController < ApplicationController
  def create
    # TODO:長いので何とかしたい
    reserve = Reserve.new(
      plan_id: params[:plan_id],
      total_bill: params[:total_bill],
      date: params[:date].to_date,
      term: params[:term],
      head_count: params[:head_count],
      breakfast: params[:breakfast],
      early_check_in: params[:early_check_in],
      sightseeing: params[:sightseeing],
      username: params[:username],
      contact: params[:contact],
      tel: params[:tel],
      email: params[:email],
      comment: params[:comment],
      session_token: SecureRandom.base64,
      session_expires_at: DateTime.now + Rational(5, 24 * 60),
      is_definitive_regist: false
    )
    reserve.valid?
    reserve.save

    render json: generate_response_body(reserve)
    # TODO:permitみたいなの必要かも
  end


  def definitive_regist
    # TODO:permitみたいなの必要かも
    reserve = Reserve.find(params[:reserve_id])

    unless reserve.session_token == params[:session_token]
      render status: 400 and return
    end

    # TODO:レコードが見つからない時は404エラー
    # TODO:is_definitive_registがtrueならばエラーとする

    reserve.is_definitive_regist = true
    reserve.session_token = nil
    reserve.session_expires_at = nil

    reserve.valid?
    reserve.save

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
end
