class User < ApplicationRecord
  include Signupable
  include Onboardable
  include Billable

  scope :subscribed, -> { where(paying_customer: true) }

  def finished_onboarding?
    stripe_subscription_id?
  end
end
