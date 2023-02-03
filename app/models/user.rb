# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  # FIXME:Reserveと共通化
  # NOTE: メールアドレスのバリデーションは、input type="email">と同じとした。
  # https://developer.mozilla.org/ja/docs/Web/HTML/Element/input/email
  # https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
  DeviseTokenAuthEmailValidator::EMAIL_REGEXP = /\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

  validates :username, presence: true
  validates :tel, allow_nil: true, length: { is: 11 }
  validates :rank, inclusion: { in: ['premium', 'normal'] }
  validates :gender, presence: true, inclusion: { in: [0, 1, 2, 9] }
end
