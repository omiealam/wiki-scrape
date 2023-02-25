class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flashes

  # TODO: : make user be paying subscriber to access this

  def index
    @downloads = Download.all.where(user_id: current_user.id)
  end

  private

  def set_flashes
    if params[:subscribed] == 'true'
      current_user.delay.set_stripe_subscription
      flash.now[:notice] = 'Your account is now active!'
    end
  end
end
