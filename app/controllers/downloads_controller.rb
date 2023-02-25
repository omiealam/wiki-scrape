class DownloadsController < ApplicationController

  def create
    page = Wikipedia.find(download_params[:input])

    if(download_params[:is_pro] == "true")
       # TODO: Handle illegal access of pro settings (fail safely)
      authenticate_user!
      # TODO: Make sure user is paying customer
      puts download_params
      Download.create(page_url: page.fullurl, page_title: page.title, belongs_to_pro: true, user_id: current_user.id, text_requested: download_params[:text_requested], images_requested: download_params[:images_requested], links_requested: download_params[:links_requested])
    else
      Download.create(page_url: page.fullurl, page_title: page.title, belongs_to_pro: false, text_requested: download_params[:text_requested])
    end
  end

  private

  def download_params
    params.require(:download).permit(:input, :is_pro, :text_requested, :images_requested, :links_requested)
  end
end
