class Reserve < ApplicationRecord
  ADDITIONAL_PLAN_PRICE = 1_000

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

  # privateでもいい気がするがテストが大変かも。
  # calc_total_billはreduce使ってもいい気がしている
  # 引数でroom_billを取得するようにする
  def calc_total_bill
    _total_bill = plan.room_bill * head_count * term

    term.times do |num|
      rest_date = date
      rest_date += num
      if rest_date.wday == 0 || rest_date.wday == 6
        _total_bill += plan.room_bill * 0.25 * head_count
      end
    end
    _total_bill += ADDITIONAL_PLAN_PRICE * head_count * term if breakfast
    _total_bill += ADDITIONAL_PLAN_PRICE * head_count if early_check_in
    _total_bill += ADDITIONAL_PLAN_PRICE * head_count if sightseeing

    _total_bill
  end
end
