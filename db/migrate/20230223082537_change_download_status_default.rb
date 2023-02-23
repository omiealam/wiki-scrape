class ChangeDownloadStatusDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :downloads, :download_completed, false
  end
end
