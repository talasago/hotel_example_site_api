class AddRoomType < ActiveRecord::Migration[7.0]
  def change
    create_table(:room_types) do |t|
      t.string 'room_type_name'
      t.string 'room_category_name'
      t.integer 'min_capacity'
      t.integer 'max_capacity'
      t.integer 'room_size'
      t.string 'facilities', array: true
    end
  end
end
