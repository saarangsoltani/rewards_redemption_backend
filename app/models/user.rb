class User < ApplicationRecord
  has_secure_password

  def new_jwt_token
    JWT.encode(
      { user_id: id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base
    )
  end
end
