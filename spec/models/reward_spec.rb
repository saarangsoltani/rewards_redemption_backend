require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe '#available?' do
    context 'when qty_available is greater than 0' do
      it 'returns true' do
        reward = build(:reward, qty_available: 5)
        expect(reward.available?).to be true
      end
    end

    context 'when qty_available is 0' do
      it 'returns false' do
        reward = build(:reward, qty_available: 0)
        expect(reward.available?).to be false
      end
    end
  end
end
