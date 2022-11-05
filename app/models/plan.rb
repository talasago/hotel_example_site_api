class Plan < ApplicationRecord
  belongs_to :room_type, optional: true
end
