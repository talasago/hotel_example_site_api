class MemberRankAllowNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :member_rank, true
    change_column_default :users, :member_rank, 'premium'
  end
end
