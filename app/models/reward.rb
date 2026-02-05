class Reward < ApplicationRecord
  def available?
    qty_available > 0
  end
end
