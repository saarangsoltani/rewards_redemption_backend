# spec/requests/api/v1/auth_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  let!(:user) { User.create!(email: "user@thanx.com", password: "pass1234") }

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns a JWT token and user json" do
        post "/api/v1/auth/login", params: { email: "user@thanx.com", password: "pass1234" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["token"]).to be_present
        expect(json["user"]).to include(
          "id" => user.id,
          "email" => user.email,
          "rewards_points_balance" => user.rewards_points_balance
        )
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post "/api/v1/auth/login", params: { email: "user@thanx.com", password: "invalid_password" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("invalid credentials")
      end
    end
  end
end
