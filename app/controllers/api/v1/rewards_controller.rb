module Api
  module V1
    class RewardsController < ApplicationController
      def index
        sleep 1.seconds
        rewards = Reward.all
        render json: rewards, request: request
      end
    end
  end
end
