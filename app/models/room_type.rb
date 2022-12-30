class RoomType < ApplicationRecord
  has_many :plans

  def room_category_type_name
    [room_category_name, room_type_name].join
  end
end
