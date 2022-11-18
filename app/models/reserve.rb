class Reserve < ApplicationRecord
  validates :plan_id, presence: true
  validates :total_bill, presence: true
  validates :date, presence: true
  validates :term, presence: true
  validates :head_count, presence: true
  validates :username, presence: true
  validates :contact, presence: true
  validates :email, presence: true, if: -> { contact == 'email' }
  validates :tel, presence: true, if: -> { contact == 'tel' }

  attribute :term_end, :date, default: :term_end

  def term_end
    date + term
  end
end
