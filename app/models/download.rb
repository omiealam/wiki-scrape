class Download < ApplicationRecord
  has_one_attached :text_file
  has_one_attached :links_csv
  has_many_attached :images
  has_one_attached :output_folder

  def perform_download
    # Create if statements for various cases
    perform_text_download if self.text_requested
    perform_images_download if self.images_requested
    perform_links_download if self.links_requested
    #construct_download
    self.update(download_completed: true)
  end

  private

  def perform_text_download
    t = Tempfile.new
    page = Wikipedia.find(self.page_url)
    File.open(t, 'w') { |file| file.write("= #{page.title.upcase} =" +"\n" +"\n" + page.text) }
    self.text_file.attach(io: File.open(t), filename: "#{self.page_title}.txt", content_type: "application/txt")
    t.close
    t.unlink
  end

  def perform_links_download
    t = Tempfile.new
    page = Wikipedia.find(self.page_url)
    CSV.open(t, "w") do |csv|
      page.extlinks.each { |link| csv << [link] }
    end
    self.links_csv.attach(io: File.open(t), filename: "#{self.page_title}_links.csv", content_type: "application/csv")
    t.close
    t.unlink
  end

  def perform_images_download
    page = Wikipedia.find(self.page_url)
    page.image_urls.each do |url|
      t = Tempfile.new
      download = URI.open(url)
      IO.copy_stream(download, t)
      self.images.attach(io: File.open(t), filename: "#{download.base_uri.to_s.split('/')[-1]}", content_type: "application/image")
      t.close
      t.unlink
    end
  end
end
