# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  # NOTE:DeviseTokenAuthでemail形式変える方法が他に無さそうだったため、やむなく定数に再代入
  DeviseTokenAuthEmailValidator::EMAIL_REGEXP = Constants::EMAIL_REGEXP

  validates :username, presence: true
  validates :tel, allow_nil: true, length: { is: 11 }
  validates :rank, inclusion: { in: ['premium', 'normal'] }
  validates :gender, presence: true, inclusion: { in: [0, 1, 2, 9] }
end
