class Reserve < ApplicationRecord
  ADDITIONAL_PLAN_PRICE = 1_000
  ADD_ROOM_BILL_RATE_SAT_AND_SUN = 0.25

  belongs_to :plan

  validates :plan_id, presence: true
  validates :total_bill, presence: true, numericality: { equal_to: :calc_total_bill }
  validates :date, presence: true,
                   comparison: {
                     greater_than_or_equal_to: Proc.new { Date.today },
                     less_than_or_equal_to: Proc.new { Date.today + 3.months }
                   }
  validates :term, presence: true
  validate  :validate_term
  validates :head_count, presence: true
  validate  :validate_head_count
  validates :username, presence: true
  validates :contact, presence: true, inclusion: { in: ['no', 'email', 'tel'] }
  # NOTE: メールアドレスのバリデーションは、input type="email">と同じとした。
  # https://developer.mozilla.org/ja/docs/Web/HTML/Element/input/email
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  EMAIL_REGEXP = /\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
  validates :email, presence: true, if: -> { contact == 'email' },
                    format: { with: EMAIL_REGEXP, message: 'invalid email format' }
  validates :tel, presence: true, if: -> { contact == 'tel' }, length: { is: 11 }

  def end_date
    date + term
  end

  private

  def validate_term
    return if plan_id.blank? || term.blank?

    unless term.between?(plan.min_term, plan.max_term)
      errors.add(:term, 'term is not in range')
    end
  end

  def validate_head_count
    return if plan_id.blank? || head_count.blank?

    unless head_count.between?(plan.min_head_count, plan.max_head_count)
      errors.add(:head_count, 'head_count is not in range')
    end
  end

  def calc_total_bill
    return if plan_id.blank? || term.blank? || date.blank?

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
