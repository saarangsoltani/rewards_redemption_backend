require 'rails_helper'

RSpec.describe Api::V1::RedemptionsController, type: :request do
  let(:user) { create(:user, rewards_points_balance: 1000) }
  let(:reward) { create(:reward, points_cost: 500, qty_available: 10) }

  before do
    allow_any_instance_of(Api::V1::RedemptionsController).to receive(:current_user).and_return(user)
  end

  describe 'POST /api/v1/redemptions' do
    context 'when redemption is successful' do
      it 'returns 201 created status' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        expect(response).to have_http_status(:created)
      end

      it 'returns success true' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end

      it 'returns redemption data' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['data']['redemption']).to be_present
        expect(json_response['data']['redemption']['points_consumed']).to eq(500)
      end

      it 'returns updated user balance' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['data']['user']['rewards_points_balance']).to eq(500)
      end

      it 'returns success message' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Reward redeemed successfully')
      end

      it 'creates a redemption record' do
        expect {
          post '/api/v1/redemptions', params: { reward_id: reward.id }
        }.to change(Redemption, :count).by(1)
      end
    end

    context 'when user has insufficient points' do
      let(:user) { create(:user, rewards_points_balance: 100) }

      it 'returns 402 payment required status' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        expect(response).to have_http_status(:payment_required)
      end

      it 'returns success false' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end

      it 'returns error message' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Insufficient points')
      end

      it 'does not create a redemption' do
        expect {
          post '/api/v1/redemptions', params: { reward_id: reward.id }
        }.not_to change(Redemption, :count)
      end
    end

    context 'when reward is unavailable' do
      before do
        allow_any_instance_of(Reward).to receive(:available?).and_return(false)
      end

      it 'returns 410 gone status' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        expect(response).to have_http_status(:gone)
      end

      it 'returns success false' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end

      it 'returns error message' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Reward is no longer available')
      end

      it 'does not create a redemption' do
        expect {
          post '/api/v1/redemptions', params: { reward_id: reward.id }
        }.not_to change(Redemption, :count)
      end
    end

    context 'when reward is not found' do
      it 'returns 404 not found status' do
        post '/api/v1/redemptions', params: { reward_id: 99999 }

        expect(response).to have_http_status(:not_found)
      end

      it 'returns success false' do
        post '/api/v1/redemptions', params: { reward_id: 99999 }

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end

      it 'returns error message' do
        post '/api/v1/redemptions', params: { reward_id: 99999 }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Reward not found')
      end
    end

    context 'when balance update fails' do
      before do
        allow_any_instance_of(User).to receive(:deduct_reward_points).and_return(false)
      end

      it 'returns 422 unprocessable entity status' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Failed to deduct points')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(RedemptionService).to receive(:call).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns 500 internal server error status' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns success false' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
      end

      it 'returns generic error message' do
        post '/api/v1/redemptions', params: { reward_id: reward.id }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('An unexpected error occurred. Please try again later.')
      end
    end

    context 'service integration' do
      it 'calls RedemptionService with correct parameters' do
        expect(RedemptionService).to receive(:call).with(user, reward).and_call_original

        post '/api/v1/redemptions', params: { reward_id: reward.id }
      end
    end
  end
end
