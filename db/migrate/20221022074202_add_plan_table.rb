class AddPlanTable < ActiveRecord::Migration[7.0]
  def change
    create_table(:plans) do |t|
      t.string 'plan_name'
      t.integer 'price'
      t.integer 'number_of_guests_min'
      t.integer 'number_of_guests_max'
      t.integer 'number_of_stays_min'
      t.integer 'number_of_stays_max'
      t.string 'room_type'
      t.string 'member_rank'
    end
  end
end
