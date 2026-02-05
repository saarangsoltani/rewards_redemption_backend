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
    puts "Created user: #{user.email} with #{user.rewards_points_balance} points"
  else
    puts "User #{user.email} already exists"
  end
end
