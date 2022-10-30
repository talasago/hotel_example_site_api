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
  end
end
