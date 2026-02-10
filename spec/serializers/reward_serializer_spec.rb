require "rails_helper"

RSpec.describe RewardSerializer do
  let(:request) { instance_double(ActionDispatch::Request, base_url: "http://test.host") }
  let(:reward) { create(:reward, qty_available: 0, image_url: "/images/starbucks.jpg") }

  it "includes computed attributes" do
    serializer = described_class.new(reward, request: request)
    attributes = serializer.attributes

    expect(attributes.keys).to include(:available, :image_url_full)
    expect(attributes[:available]).to be false
    expect(attributes[:image_url_full]).to eq("http://test.host/images/starbucks.jpg")
  end
end
