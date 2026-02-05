module Api
  module V1
    class AuthController < ApplicationController
      def create
        user = User.find_by(email: auth_params[:email])

        if user&.authenticate(auth_params[:password])
          token = user.new_jwt_token
          render json: {
            user: { id: user.id, email: user.email, rewards_points_balance: user.rewards_points_balance },
            token: token
          }, status: :ok
        else
          render json: { error: "invalid credentials" }, status: :unauthorized
        end
      end

      private

      def auth_params
        params.permit(:email, :password)
      end
    end
  end
end
