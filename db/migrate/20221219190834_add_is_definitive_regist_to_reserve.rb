class AddIsDefinitiveRegistToReserve < ActiveRecord::Migration[7.0]
  def change
    add_column :reserves, :is_definitive_regist, :boolean, null: false, default: false
  end
end
