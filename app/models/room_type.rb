class RoomType < ApplicationRecord
  has_many :plans

  def room_category_type_name
    return nil if room_category_name.nil? && room_type_name.nil?

    [room_category_name, room_type_name].join
  end
end
