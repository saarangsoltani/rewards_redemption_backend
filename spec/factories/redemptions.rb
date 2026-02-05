FactoryBot.define do
  factory :redemption do
    association :user
    association :reward
    points_consumed { 100 }
  end
end
