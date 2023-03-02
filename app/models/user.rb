# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :username, presence: true
  validates :tel, allow_nil: true, length: { is: 11 }
  validates :rank, inclusion: { in: ['premium', 'normal'] }
  validates :gender, presence: true, inclusion: { in: [0, 1, 2, 9] }
end
