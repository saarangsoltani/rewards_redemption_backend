class Reward < ApplicationRecord
  validates :name, :description, :image_url, presence: true
  validates :points_cost, presence: true,
                          numericality: { only_integer: true, greater_than: 0 }
  validates :qty_available, presence: true,
                            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :image_url, format: { with: /\A\/[\w\/\-.]+\z/, message: "must be a relative path starting with /" }

  has_many :redemptions, dependent: :restrict_with_error # prevent reward.destroy while redemptions exist
  def available?
    qty_available > 0
  end
end
