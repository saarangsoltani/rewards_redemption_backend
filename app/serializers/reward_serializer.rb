class RewardSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points_cost, :qty_available, :available, :image_url_full, :image_url

  def available
    object.available?
  end

  def image_url_full
    "#{instance_options[:request].base_url}#{object.image_url}"
  end
end
