class User < ApplicationRecord
  has_secure_password

  has_many :redemptions, dependent: :destroy

  def new_jwt_token
    JWT.encode(
      { user_id: id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base
    )
  end

  def deduct_reward_points(amount)
    if amount.is_a?(Integer) && amount > 0 && rewards_points_balance >= amount
      update(rewards_points_balance: rewards_points_balance - amount)
    else
      false
    end
  end
end
