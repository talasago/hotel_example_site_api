class Api::V1::ReservesController < ApplicationController
  def create
    reserve = Reserve.new(
      plan_id: params[:plan_id],
      total_bill: params[:total_bill],
      date: params[:date],
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

    render :json
    # TODO:permitみたいなの必要かも
  end
end
