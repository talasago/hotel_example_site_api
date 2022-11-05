class RoomType < ApplicationRecord
  has_many :plans

  attribute :room_category_type_name, :string
  after_find -> { self.room_category_type_name = [room_category_name, room_type_name].join }
end
