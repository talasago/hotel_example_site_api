class ModifyColumnCloserToOriginal < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :member_rank, :rank
    rename_column :users, :birth_date, :birthday
    rename_column :users, :receive_notifications, :notification
    rename_column :users, :name, :username
    change_column :users, :gender, :string, default: 'unregistered'

    rename_column :plans, :plan_name, :name
    rename_column :plans, :price, :room_bill
    rename_column :plans, :number_of_guests_min, :min_head_count
    rename_column :plans, :number_of_guests_max, :max_head_count
    rename_column :plans, :number_of_stays_min, :min_term
    rename_column :plans, :number_of_stays_max, :max_term

    rename_column :plans, :room_type, :room_type_id
    change_column :plans, :room_type_id, 'integer USING CAST(room_type_id AS integer)'

    rename_column :plans, :member_rank, :only
  end
end
