class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :rewards_points_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

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
