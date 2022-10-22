class UserMemberRankToString < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :member_rank, :string, null: false
    change_column_default :users, :member_rank, nil
  end
end
