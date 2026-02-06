class RedemptionService
  attr_reader :user, :reward, :redemption, :error_message, :error_code

  def self.call(*args)
    service = new(*args)
    service.redeem
    service
  end

  def initialize(user, reward)
    @user = user
    @reward = reward
    @redemption = nil
    @error_message = nil
    @error_code = nil
  end

  def redeem
    ActiveRecord::Base.transaction do
      reward.with_lock do # lock early to avoid race conditions
        validate_reward_availability!
        validate_user_balance!
        create_redemption!
        update_user_balance!
        update_reward_quantity!
      end
      true
    end
  rescue StandardError => e
    handle_error(e)
    false
  end

  def success?
    redemption.present? && error_message.nil?
  end

  private

  def validate_reward_availability!
    unless reward.available?
      fail_with(:reward_unavailable, "Reward is no longer available")
    end
  end

  def validate_user_balance!
    if user.rewards_points_balance < reward.points_cost
      fail_with(:insufficient_points, "Insufficient points")
    end
  end

  def create_redemption!
    @redemption = user.redemptions.create!(
      reward: reward,
      points_consumed: reward.points_cost
    )
  end

  def update_user_balance!
    unless user.deduct_reward_points(reward.points_cost)
      fail_with(:balance_update_failed, "Failed to deduct points")
    end
  end

  def update_reward_quantity!
    reward.decrement!(:qty_available)
  end

  def fail_with(code, message)
    @error_code = code
    @error_message = message
    raise StandardError, message
  end

  def handle_error(error)
    # If error_code wasn't set by fail_with, determine it from exception type
    unless @error_code
      @error_code = :unknown_error
    end
    @error_message = error.message
  end
end
