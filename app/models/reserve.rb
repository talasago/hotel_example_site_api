class Reserve < ApplicationRecord
  ADDITIONAL_PLAN_PRICE = 1_000
  ADD_ROOM_BILL_RATE_SAT_AND_SUN = 0.25

  belongs_to :plan

  validates :plan_id, presence: true
  validates :total_bill, presence: true, numericality: true
  validates :date, presence: true
  validates :term, presence: true
  validates :head_count, presence: true
  validates :username, presence: true
  validates :contact, presence: true
  validates :email, presence: true, if: -> { contact == 'email' }
  validates :tel, presence: true, if: -> { contact == 'tel' }
  validate :validate_total_bill

  def term_end
    date + term
  end

  private

  def validate_total_bill
    return if !plan_id.present? && !term.present? && !date.present?

    if total_bill != calc_total_bill
      errors.add(:total_bill, 'Invalid amounts have been set.')
    end
  end

  def calc_total_bill
    total_bill_ = [*0..term - 1].map do |add_day|
      wday = (date + add_day).wday
      wday == 0 || wday == 6 ?
        plan.room_bill * head_count * (1 + ADD_ROOM_BILL_RATE_SAT_AND_SUN) :
        plan.room_bill * head_count
    end.reduce(:+)

    total_bill_ += ADDITIONAL_PLAN_PRICE * head_count * term if breakfast
    total_bill_ += ADDITIONAL_PLAN_PRICE * head_count if early_check_in
    total_bill_ += ADDITIONAL_PLAN_PRICE * head_count if sightseeing

    total_bill_
  end
end
