class AddDefaultValueReserve < ActiveRecord::Migration[7.0]
  def change
    change_column_default :reserves, :breakfast, false
    change_column_default :reserves, :early_check_in, false
    change_column_default :reserves, :sightseeing, false
  end
end
