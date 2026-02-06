require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#new_jwt_token' do
    let(:user) { User.create!(email: "user@thanx.com", password: "pass1234") }

    it 'returns a valid JWT token containing the user_id' do
      token = user.new_jwt_token
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256').first

      expect(decoded['user_id']).to eq(user.id)
      expect(decoded['exp']).to be_present
    end
  end
  describe '#deduct_reward_points' do
    let(:user) { create(:user, rewards_points_balance: 1000) }

    context 'when deduction is valid' do
      it 'deducts points from the user balance' do
        expect(user.deduct_reward_points(500)).to be true
        expect(user.reload.rewards_points_balance).to eq(500)
      end

      it 'deducts all points when amount equals balance' do
        expect(user.deduct_reward_points(1000)).to be true
        expect(user.reload.rewards_points_balance).to eq(0)
      end
    end

    context 'when deduction is invalid' do
      it 'returns false when amount exceeds balance' do
        expect(user.deduct_reward_points(1500)).to be false
        expect(user.reload.rewards_points_balance).to eq(1000)
      end

      it 'returns false when amount is zero' do
        expect(user.deduct_reward_points(0)).to be false
        expect(user.reload.rewards_points_balance).to eq(1000)
      end

      it 'returns false when amount is negative' do
        expect(user.deduct_reward_points(-100)).to be false
        expect(user.reload.rewards_points_balance).to eq(1000)
      end

      it 'returns false when amount is not an integer' do
        expect(user.deduct_reward_points(50.5)).to be false
        expect(user.reload.rewards_points_balance).to eq(1000)
      end
    end

    context 'when user has zero balance' do
      let(:user) { create(:user, rewards_points_balance: 0) }

      it 'returns false when trying to deduct any amount' do
        expect(user.deduct_reward_points(1)).to be false
        expect(user.reload.rewards_points_balance).to eq(0)
      end
    end
  end
end
