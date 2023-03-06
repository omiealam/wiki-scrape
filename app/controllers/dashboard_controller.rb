class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flashes

  def index
    # TODO: Make footer work correctly on dashboard index page
    @downloads = Download.all.where(user_id: current_user.id)
    render :layout=>'home'
  end

  private

  def set_flashes
    if params[:subscribed] == 'true'
      current_user.set_stripe_subscription
      current_user.update(paying_customer: true)
      flash.now[:notice] = 'Your Pro plan is now active!'
    end
  end
end
