require "rails_helper"

RSpec.describe Authenticatable, type: :controller do
  controller(ActionController::Base) do
    include Authenticatable

    def index
      render json: { ok: true }
    end
  end

  let(:secret) { Rails.application.credentials.secret_key_base }
  let(:user) { create(:user) }

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "GET #index" do
    context "when the Authorization header is missing" do
      it "returns 401 unauthorized with error payload" do
        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
      end
    end

    context "when the token is malformed" do
      it "returns 401 unauthorized" do
        request.headers["Authorization"] = "Bearer not-a-jwt"

        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
      end
    end

    context "when the token is expired" do
      it "returns 401 unauthorized" do
        token = JWT.encode({ user_id: user.id, exp: 1.hour.ago.to_i }, secret, "HS256")
        request.headers["Authorization"] = "Bearer #{token}"

        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
      end
    end

    context "when the token is valid but the user cannot be found" do
      it "returns 401 unauthorized" do
        token = JWT.encode({ user_id: 0 }, secret, "HS256")
        request.headers["Authorization"] = "Bearer #{token}"

        get :index

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
      end
    end

    context "when the token is valid" do
      it "returns 200 ok" do
        token = JWT.encode({ user_id: user.id }, secret, "HS256")
        request.headers["Authorization"] = "Bearer #{token}"

        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("ok" => true)
      end

      it "sets current_user from the token" do
        token = JWT.encode({ user_id: user.id }, secret, "HS256")
        request.headers["Authorization"] = "Bearer #{token}"

        get :index

        expect(controller.send(:current_user)).to eq(user)
      end
    end
  end
end
