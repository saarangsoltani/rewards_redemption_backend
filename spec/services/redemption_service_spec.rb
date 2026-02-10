require 'rails_helper'

RSpec.describe RedemptionService do
  let(:user) { create(:user, rewards_points_balance: 100) }
  let(:reward) { create(:reward, points_cost: 50, qty_available: 10) }

  describe '.call' do
    it 'instantiates and calls redeem on the service' do
      service = RedemptionService.call(user, reward)

      expect(service).to be_a(RedemptionService)
      expect(service.user).to eq(user)
      expect(service.reward).to eq(reward)
    end
  end

  describe '#redeem' do
    context 'when redemption is successful' do
      it 'returns true' do
        service = RedemptionService.new(user, reward)
        result = service.redeem

        expect(result).to be true
      end

      it 'creates a redemption record' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.to change(Redemption, :count).by(1)
        expect(service.redemption).to be_persisted
        expect(service.redemption.reward).to eq(reward)
        expect(service.redemption.user).to eq(user)
        expect(service.redemption.points_consumed).to eq(50)
      end

      it 'deducts points from user balance' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.to change { user.reload.rewards_points_balance }.from(100).to(50)
      end

      it 'decrements reward quantity by 1' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.to change { reward.reload.qty_available }.from(10).to(9)
      end

      it 'sets success? to true' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.success?).to be true
      end

      it 'does not set error_message' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_message).to be_nil
      end

      it 'does not set error_code' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_code).to be_nil
      end
    end

    context 'when user has insufficient points' do
      let(:user) { create(:user, rewards_points_balance: 10) }

      it 'returns false' do
        service = RedemptionService.new(user, reward)
        result = service.redeem

        expect(result).to be false
      end

      it 'does not create a redemption' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change(Redemption, :count)
        expect(service.redemption).to be_nil
      end

      it 'does not change user balance' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change { user.reload.rewards_points_balance }
      end

      it 'does not change reward quantity' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change { reward.reload.qty_available }
      end

      it 'sets error_code to :insufficient_points' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_code).to eq(:insufficient_points)
      end

      it 'sets error_message' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_message).to eq("Insufficient points")
      end

      it 'sets success? to false' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.success?).to be false
      end
    end
    context 'when reward is not available' do
      let(:reward) { create(:reward, qty_available: 0) }

      before do
        allow(reward).to receive(:available?).and_return(false)
      end

      it 'returns false' do
        service = RedemptionService.new(user, reward)
        result = service.redeem

        expect(result).to be false
      end

      it 'does not create a redemption' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change(Redemption, :count)
      end

      it 'does not change user balance' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change { user.reload.rewards_points_balance }
      end

      it 'sets error_code to :reward_unavailable' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_code).to eq(:reward_unavailable)
      end

      it 'sets error_message' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.error_message).to eq("Reward is no longer available")
      end

      it 'sets success? to false' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.success?).to be false
      end
    end
  end

  context 'when user.deduct_reward_points fails' do
    before do
      allow(user).to receive(:deduct_reward_points).and_return(false)
    end

    it 'returns false' do
      service = RedemptionService.new(user, reward)
      result = service.redeem

      expect(result).to be false
    end

    it 'rolls back the transaction' do
      service = RedemptionService.new(user, reward)

      expect { service.redeem }.not_to change(Redemption, :count)
    end

    it 'sets error_code to :balance_update_failed' do
      service = RedemptionService.new(user, reward)
      service.redeem

      expect(service.error_code).to eq(:balance_update_failed)
    end

    it 'sets error_message' do
      service = RedemptionService.new(user, reward)
      service.redeem

      expect(service.error_message).to eq("Failed to deduct points")
    end
  end

  context 'when creating redemption fails with validation error' do
    before do
      allow_any_instance_of(Redemption).to receive(:save!).and_raise(
        ActiveRecord::RecordInvalid.new(Redemption.new)
      )
    end

    it 'returns false' do
      service = RedemptionService.new(user, reward)
      result = service.redeem

      expect(result).to be false
    end

    it 'does not create a redemption' do
      service = RedemptionService.new(user, reward)

      expect { service.redeem }.not_to change(Redemption, :count)
    end

    it 'sets error_code to :unknown_error' do
      service = RedemptionService.new(user, reward)
      service.redeem

      expect(service.error_code).to eq(:unknown_error)
    end

    it 'sets error_message' do
      service = RedemptionService.new(user, reward)
      service.redeem

      expect(service.error_message).to be_present
    end
  end

  context 'transaction rollback behavior' do
    context 'when point deduction fails after redemption is created' do
      before do
        # Make deduct_reward_points! fail
        allow(user).to receive(:deduct_reward_points).and_return(false)
      end

      it 'rolls back all database changes' do
        service = RedemptionService.new(user, reward)

        expect { service.redeem }.not_to change(Redemption, :count)
        expect { service.redeem }.not_to change { user.reload.rewards_points_balance }
        expect { service.redeem }.not_to change { reward.reload.qty_available }
      end
    end
  end

  context 'race condition protection' do
    it 'locks the reward and user records' do
      service = RedemptionService.new(user, reward)

      expect(reward).to receive(:lock!).and_call_original
      expect(user).to receive(:lock!).and_call_original
      service.redeem
    end

    context 'when two requests try to redeem the last reward' do
      let(:reward) { create(:reward, points_cost: 50, qty_available: 1) }
      let(:user1) { create(:user, rewards_points_balance: 100) }
      let(:user2) { create(:user, rewards_points_balance: 100) }

      it 'only allows one redemption to succeed' do
        # This test simulates concurrent requests
        # In practice, you'd need parallel execution to truly test this
        service1 = RedemptionService.new(user1, reward)
        service2 = RedemptionService.new(user2, reward)

        service1.redeem

        reward.reload

        # Second redemption should fail
        result = service2.redeem
        expect(result).to be false
      end
    end
  end

  describe '#success?' do
    context 'when redemption exists and no error' do
      it 'returns true' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(service.success?).to be true
      end
    end

    context 'when redemption does not exist' do
      it 'returns false' do
        service = RedemptionService.new(user, reward)
        allow(user).to receive(:rewards_points_balance).and_return(0)
        service.redeem

        expect(service.success?).to be false
      end
    end

    context 'when error_message is present' do
      it 'returns false' do
        service = RedemptionService.new(user, reward)
        allow(reward).to receive(:available?).and_return(false)
        service.redeem

        expect(service.success?).to be false
      end
    end
  end

  describe 'edge cases' do
    context 'when user has exact points needed' do
      let(:user) { create(:user, rewards_points_balance: 50) }

      it 'successfully redeems' do
        service = RedemptionService.new(user, reward)
        result = service.redeem

        expect(result).to be true
        expect(user.reload.rewards_points_balance).to eq(0)
      end
    end

    context 'when reward has quantity of 1' do
      let(:reward) { create(:reward, points_cost: 50, qty_available: 1) }

      it 'successfully redeems and sets quantity to 0' do
        service = RedemptionService.new(user, reward)
        service.redeem

        expect(reward.reload.qty_available).to eq(0)
      end
    end
  end
end
