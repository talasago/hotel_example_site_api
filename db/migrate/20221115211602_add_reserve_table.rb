class AddReserveTable < ActiveRecord::Migration[7.0]
  def change
    create_table(:reserves) do |t|
      t.integer 'plan_id', null: false
      t.integer 'total_bill', null: false
      t.date 'date', null: false
      t.integer 'term', null: false
      t.integer 'head_count', null: false
      t.string 'username', null: false
      t.boolean 'breakfast'
      t.boolean 'early_check_in'
      t.boolean 'sightseeing'
      t.string 'contact', null: false
      t.string 'email'
      t.string 'tel'
      t.string 'comment'
    end
  end
end
