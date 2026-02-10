puts "Creating seed data for users"

users = [
  {
    email: "user1@thanx.com",
    password: "pass1234",
    rewards_points_balance: Faker::Number.between(from: 1000, to: 2000)
  },
  {
    email: "user2@thanx.com",
    password: "pass1234",
    rewards_points_balance: Faker::Number.between(from: 1000, to: 2000)
  },
  {
    email: "user3@thanx.com",
    password: "pass1234",
    rewards_points_balance: Faker::Number.between(from: 1000, to: 2000)
  }

]

users.each do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email])
  if user.new_record?
    user.assign_attributes(user_data)
    user.save!
    puts "Created user: \e[33m#{user.email}\e[0m - Reward points: #{user.rewards_points_balance} points"
  else
    puts "User #{user.email} already exists"
  end
end

# ---------------- Rewards
puts "----------------------------------"
puts "Creatng seed data for rewards"

rewards = [
  {
    name: "Tim Hortons Gift Card",
    description: "Enjoy coffee and snacks from Tim Hortons.",
    points_cost: 40,
    qty_available: 50,
    image_url: "/images/tim_hortons.png"
  },
  {
    name: "Amazon.ca Gift Card",
    description: "Shop for anything on Amazon.ca with this gift card.",
    points_cost: 200,
    qty_available: 30,
    image_url: "/images/amazon.png"
  },
    {
    name: "Metro Grocery Voucher",
    description: "Shop for groceries at Metro stores across Canada.",
    points_cost: 60,
    qty_available: 45,
    image_url: "/images/metro.png"
  },
  {
    name: "Canadian Tire Coupon",
    description: "Save on purchases at Canadian Tire stores.",
    points_cost: 400,
    qty_available: 25,
    image_url: "/images/canadian_tire.png"
  },
  {
    name: "Hudson’s Bay Gift Card",
    description: "Shop fashion and home at The Bay.",
    points_cost: 160,
    qty_available: 20,
    image_url: "/images/hudson_bay.png"
  },
    {
    name: "Best Buy Gift Card",
    description: "Electronics, appliances, and gadgets at Best Buy.",
    points_cost: 180,
    qty_available: 15,
    image_url: "/images/best_buy.png"
  },
  {
    name: "Shoppers Drug Mart Voucher",
    description: "Spend on essentials or beauty at Shoppers Drug Mart.",
    points_cost: 100,
    qty_available: 40,
    image_url: "/images/shoppers_drug_mart.png"
  },
  {
    name: "Starbucks Voucher",
    description: "Get your favorite drinks and treats at Starbucks.",
    points_cost: 60,
    qty_available: 5,
    image_url: "/images/starbucks.jpg"
  },
    {
    name: "Cineplex Movie Ticket",
    description: "Redeem for a movie experience at Cineplex theaters.",
    points_cost: 80,
    qty_available: 40,
    image_url: "/images/cineplex.png"
  },
  {
    name: "Uber Ride Credit",
    description: "Travel anywhere with Uber ride credits.",
    points_cost: 120,
    qty_available: 30,
    image_url: "/images/uber.png"
  }

]

rewards.each do |reward_data|
  reward = Reward.find_or_initialize_by(name: reward_data[:name])
  if reward.new_record?
    reward.assign_attributes(reward_data)
    reward.save!
    puts "Created reward: \e[33m'#{reward.name}'\e[0m - Cost: #{reward.points_cost}"
  else
    puts "reward #{reward.name} already exists"
  end
end
