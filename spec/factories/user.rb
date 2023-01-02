FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }
    username { 'TestUser' }
    rank { 'normal' }
    address { 'HOGE県' }
    tel { '00000000000' }
    gender { '9' }
    birthday { '1989/12/30' }
    notification { true }

    trait :invalid do
      username { nil }
      email { nil }
      password { nil }
    end

    trait :registed_user1 do
      email { 'ichiro@example.com' }
      password { 'password' }
    end

    trait :registed_user2 do
      email { 'sakura@example.com' }
      password { 'pass1234' }
    end
  end
end
