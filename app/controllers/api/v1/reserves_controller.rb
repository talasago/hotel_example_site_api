class Api::V1::ReservesController < ApplicationController
  def create
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
      comment: params[:comment]
    )
    reserve.valid?
    reserve.save

    render json: generate_response_body(reserve)
    # TODO:permitみたいなの必要かも
  end

  private

  def generate_response_body(reserve)
    res = reserve.as_json(except: ['plan_id'])
    res['plan_name'] = reserve.plan.as_json(only: 'name')
    res['reserve_id'] = res.delete('id')
    res['start_date'] = res.delete('date').gsub(/-/, '/')
    res['end_date'] = reserve.end_date.strftime('%Y/%m/%d')
    res
  end
end
