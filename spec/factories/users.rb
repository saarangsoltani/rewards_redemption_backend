FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    rewards_points_balance { 1 }
  end
end
