require "rails_helper"

RSpec.describe RedemptionSerializer do
  include ActiveSupport::Testing::TimeHelpers

  let(:redemption) { create(:redemption, points_consumed: 120) }

  it "exposes the computed redeemed_at attribute" do
    travel_to(Time.current) do
      redemption.update!(created_at: 2.minutes.ago)
      serializer = described_class.new(redemption)
      attributes = serializer.attributes

      expect(attributes.keys).to include(:redeemed_at)
      expect(serializer.redeemed_at).to end_with("ago")
    end
  end

  it "includes the reward relationship" do
    serializer = described_class.new(redemption)
    relationships = serializer.associations.map(&:key)

    expect(relationships).to include(:reward)
  end
end
