class ModifyColumnsToUser < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :gender, nil
    change_column :users, :gender, 'integer USING CAST(gender AS integer)'
  end
end
