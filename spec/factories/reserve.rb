FactoryBot.define do
  factory :reserve do
    # TODO:プラン毎と、additionalプラン毎、土日で金額変えた方が良い。
    plan_id { 0 }
    total_bill { 11_750 }
    date { Date.today.next_occurring(:sunday).strftime('%Y/%m/%d') }
    term { 1 }
    head_count { 1 }
    breakfast { true }
    early_check_in { true }
    sightseeing { true }
    username { 'テスト太郎' }
    contact { 'no' }
    comment { 'comment_test' }

    trait :with_tel do
      contact { 'tel' }
      tel { '09000000000' }
    end

    trait :with_email do
      contact { 'email' }
      email { 'example@example.com' }
    end

    trait :with_only_plemium do
      plan_id { 1 }
      total_bill { 31_000 }
      head_count { 2 }
    end
  end
end
