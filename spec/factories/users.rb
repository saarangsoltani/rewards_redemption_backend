FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email(domain: "thanx.com") }
    password { "pass1234" }
    rewards_points_balance { 500 }
  end
end
