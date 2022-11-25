class Reserve < ApplicationRecord
  ADDITIONAL_PLAN_PRICE = 1_000
  ADD_ROOM_BILL_RATE_SAT_AND_SUN = 0.25

  belongs_to :plan

  validates :plan_id, presence: true
  validates :total_bill, presence: true
  validates :date, presence: true
  validates :term, presence: true
  validates :head_count, presence: true
  validates :username, presence: true
  validates :contact, presence: true
  validates :email, presence: true, if: -> { contact == 'email' }
  validates :tel, presence: true, if: -> { contact == 'tel' }

  def term_end
    date + term
  end

  def calc_total_bill(room_bill)
    basic_bill(room_bill) + additional_plan_bill
  end

  private

  def basic_bill(room_bill)
    [*0..term - 1].map do |add_day|
      wday = (date + add_day).wday
      wday == 0 || wday == 6 ?
        room_bill * head_count * (1 + ADD_ROOM_BILL_RATE_SAT_AND_SUN) :
        room_bill * head_count
    end.reduce(:+)
  end

  def additional_plan_bill
    add_bill = 0
    add_bill += ADDITIONAL_PLAN_PRICE * head_count * term if breakfast
    add_bill += ADDITIONAL_PLAN_PRICE * head_count if early_check_in
    add_bill += ADDITIONAL_PLAN_PRICE * head_count if sightseeing
    add_bill
  end
end
