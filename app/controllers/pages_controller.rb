class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:logout]

  def home
    # TODO: Make footer work correctly on home page
    render :layout=>'home'
  end

  def logout
    sign_out(current_user)
    redirect_to root_path
  end

  def page
    @page_key = request.path[1..-1]
    render "pages/#{@page_key}"
  end

  def pro
  end
end
