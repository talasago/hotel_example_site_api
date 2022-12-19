class AddColumnsToReserve < ActiveRecord::Migration[7.0]
  def change
    add_column :reserves, :session_token, :string
    add_column :reserves, :session_expires_at, :datetime
  end
end
