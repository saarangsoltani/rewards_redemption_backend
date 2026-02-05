FactoryBot.define do
  factory :reward do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence(word_count: 8) }
    points_cost { Faker::Number.between(from: 20, to: 200) }
    qty_available { Faker::Number.between(from: 10, to: 100) }
    image_url { Faker::Internet.url(host: "example.com", path: "/images/starbucks.jpg") }
  end
end
