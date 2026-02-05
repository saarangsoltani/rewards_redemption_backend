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
end
