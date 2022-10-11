FactoryBot.define do
  factory :user, aliases: [:owner] do
    name { 'TestUser' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }
  end
end
