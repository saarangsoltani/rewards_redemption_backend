class RedemptionSerializer < ActiveModel::Serializer
  attributes :id, :points_consumed, :created_at, :redeemed_at

  has_one :reward

  def redeemed_at
    ActionController::Base.helpers.time_ago_in_words(object.created_at) + " ago"
  end
end
