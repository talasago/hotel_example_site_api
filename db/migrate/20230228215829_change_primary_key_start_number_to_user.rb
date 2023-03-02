class ChangePrimaryKeyStartNumberToUser < ActiveRecord::Migration[7.0]
  def up
    # seeds.rbのユーザー+1の数字
    execute "SELECT setval('users_id_seq', 5, true)"
  end

  def down
    execute "SELECT setval('users_id_seq', 1, true)"
  end
end
