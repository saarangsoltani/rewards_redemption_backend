class Reward < ApplicationRecord
  has_many :redemptions, dependent: :restrict_with_error # prevent reward.destroy while redemptions exist
  def available?
    qty_available > 0
  end
end
