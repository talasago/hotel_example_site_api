FactoryBot.define do
  factory :user do
    name { 'TestUser' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }
    member_rank { 'member' }

    trait :invalid do
      name { nil }
      email { nil }
      password { nil }
      member_rank { nil }
    end
  end
end
