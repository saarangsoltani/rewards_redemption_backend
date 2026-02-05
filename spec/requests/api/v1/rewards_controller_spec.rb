require 'rails_helper'

RSpec.describe Api::V1::RewardsController, type: :request do
  describe "GET /api/v1/rewards" do
    let!(:rewards) { create_list(:reward, 5, qty_available: 12) }

    it "returns all rewards as JSON" do
      get '/api/v1/rewards'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to be_an(Array)
      expect(json.length).to eq(5)
      reward = json.first
      expect(reward).to include(
        "id",
        "name",
        "description",
        "points_cost",
        "qty_available",
        "available",
        "image_url_full"
      )
      expect(reward["qty_available"]).to eq(12)
    end
  end
end
