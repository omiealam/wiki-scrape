class AddPageTitleToDownloads < ActiveRecord::Migration[7.0]
  def change
    add_column :downloads, :page_title, :string
  end
end
