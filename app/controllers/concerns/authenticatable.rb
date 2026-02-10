module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

    def authenticate_request!
      render_unauthorized unless current_user
    end

    def current_user
      @current_user ||= begin
        token = request.headers["Authorization"]&.split(" ")&.last
        return nil unless token

        decoded = decode_jwt_token(token)
        User.find_by(id: decoded["user_id"]) if decoded
      end
    end

    def decode_jwt_token(token)
      JWT.decode(
        token,
        Rails.application.credentials.secret_key_base,
        true,
        { algorithm: "HS256" }
      ).first
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end

    def render_unauthorized
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end
end
