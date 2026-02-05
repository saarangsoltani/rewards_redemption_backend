module Api
  module V1
    class RewardsController < ApplicationController
      def index
        rewards = Reward.all
        render json: rewards, request: request
      end
    end
  end
end
