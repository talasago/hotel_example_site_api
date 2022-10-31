FactoryBot.define do
  factory :user do
    username { 'TestUser' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }

    trait :invalid do
      username { nil }
      email { nil }
      password { nil }
    end

    trait :registed_user1 do
      email{ 'ichiro@example.com' }
      password{ 'password' }
    end

    trait :registed_user2 do
      email{ 'sakura@example.com' }
      password{ 'pass1234' }
    end

  end
end
