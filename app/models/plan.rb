class Plan < ApplicationRecord
  belongs_to :room_type, optional: true
  has_many :reserves
end
