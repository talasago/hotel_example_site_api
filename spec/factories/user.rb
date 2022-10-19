FactoryBot.define do
  factory :user do
    name { 'TestUser' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }

    trait :invalid do
      name { nil }
      email { nil }
      password { nil }
    end
  end
end
