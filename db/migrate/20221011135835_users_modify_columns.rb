class UsersModifyColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :menber_rank, :integer, default: 0
    add_column :users, :address, :string
    add_column :users, :tel, :string
    add_column :users, :gender, :integer, default: 0
    add_column :users, :birth_date, :date
    add_column :users, :recive_notifications, :boolean, default: false

    change_column :users, :name, :string, null: false
    change_column :users, :email, :string, null: false
  end
end
