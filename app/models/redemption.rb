class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  # I intentionally omitted model validation for balance/availability checks because
  # they are enforced in RedemptionService. In a real-world app, you may still
  # add model validation here to guard against redemptions created outside the service.
end
