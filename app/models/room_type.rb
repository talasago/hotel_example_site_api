class RoomType < ApplicationRecord
  has_many :plans
  #TODO: room_category_type_name
end
