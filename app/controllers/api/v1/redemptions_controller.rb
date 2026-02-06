module Api
  module V1
    class RedemptionsController < ApplicationController
      include Authenticatable
      before_action :set_reward, only: [ :create ]

      def create
        service = RedemptionService.call(current_user, @reward)

        if service.success?
          render_success(service)
        else
          render_error(service)
        end
      rescue StandardError
        render json: {
          success: false,
          error: "An unexpected error occurred. Please try again later."
        }, status: :internal_server_error
      end

      private
      def render_success(service)
        render json: {
          success: true,
          data: {
            redemption: service.redemption,
            user: {
              rewards_points_balance: current_user.reload.rewards_points_balance
            }
          },
          message: "Reward redeemed successfully"
        }, status: :created
      end

      def render_error(service)
        status_code =  case service.error_code
        when :insufficient_points
          :payment_required
        when :reward_unavailable
          :gone
        else
          :unprocessable_entity
        end
        render json: {
          success: false,
          error: service.error_message
        }, status: status_code
      end

      def set_reward
        @reward = Reward.find(params[:reward_id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          error: "Reward not found"
        }, status: :not_found
      end
    end
  end
end
