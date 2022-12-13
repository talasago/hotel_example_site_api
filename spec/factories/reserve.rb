FactoryBot.define do
  factory :reserve do
    plan_id { 2 }
    total_bill { 13_625 }
    date { Date.today.next_occurring(:sunday) }
    term { 1 }
    head_count { 1 }
    breakfast { true }
    early_check_in { true }
    sightseeing { true }
    username { 'テスト太郎' }
    contact { 'no' }
    comment { 'comment_test' }
  end
end
