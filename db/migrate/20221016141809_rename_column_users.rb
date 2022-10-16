class RenameColumnUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :menber_rank, :member_rank
    rename_column :users, :recive_notifications, :receive_notifications
  end
end
