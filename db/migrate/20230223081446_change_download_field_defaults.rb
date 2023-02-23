class ChangeDownloadFieldDefaults < ActiveRecord::Migration[7.0]
  def change
    change_column_default :downloads, :images_requested, false
    change_column_default :downloads, :links_requested, false
  end
end
