class DownloadsController < ApplicationController
  include ActiveStorage::SendZip

  def create
    @page = Wikipedia.find(create_params[:input])

    clear_old_downloads

    if page_nil?
      redirect_to root_path, alert: "That page doesn't seem to exist!"
    else
      if(create_params[:is_pro] == "true")
        authenticate_user!
        unless current_user.paying_customer
          redirect_to "/account", alert: "Activate your account to access Pro features"
        else
          create_paid_download
        end
      else
        create_free_download
      end
    end
  end

  def show
    # TODO: Make sure people can only access their own items
    @download = Download.find_by(id: show_params[:id])
    respond_to do |format|
      format.zip { send_zip construct_download, filename: "#{@download.page_title}.zip"}
    end
  end

  private

  def create_params
    params.require(:download).permit(:input, :is_pro, :text_requested, :images_requested, :links_requested)
  end

  def show_params
    params.permit(:id, :format)
  end

  def construct_download
    output = {}
    output["#{@download.page_title}"] = {}
    inner_file = output["#{@download.page_title}"]
    inner_file[:text_file] = @download.text_file if @download.text_requested
    inner_file[:links_csv] = @download.links_csv if @download.links_requested
    inner_file[:images] = construct_image_download if @download.images_requested
    return output
  end

  def construct_image_download
    arr = []
    @download.images.each {|image| arr << image}
    arr
  end

  def page_nil?
    @page.text.nil?
  end

  def create_free_download
    @download = Download.create(page_url: @page.fullurl, page_title: @page.title, belongs_to_pro: false, text_requested: create_params[:text_requested])
    # TODO: Make this a delayed job with callback to redirect to download link
    @download.perform_download
    redirect_to rails_blob_path(@download.text_file, disposition: "attachment", filename: "#{@download.page_title}.txt")
  end

  def create_paid_download
    @download = Download.create(page_url: @page.fullurl, page_title: @page.title, belongs_to_pro: true, user_id: current_user.id, text_requested: create_params[:text_requested], images_requested: create_params[:images_requested], links_requested: create_params[:links_requested])
    # TODO: use .delay(:priority => n) to give Pro download requests priority 
    @download.delay.perform_download
    redirect_to "/dashboard", notice: "That page has been added to the download queue"
  end

  def clear_old_downloads
    # TODO: Use the task delete_free_downloads once I understand Heroku pricing
    Download.where("belongs_to_pro = ?", false).where('created_at <= ?', 5.minutes.ago).destroy_all
  end
end
