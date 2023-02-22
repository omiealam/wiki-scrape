class CreateDownloads < ActiveRecord::Migration[7.0]
  def change
    create_table :downloads do |t|
      t.object :page
      t.boolean :belongs_to_pro
      t.integer :user_id
      t.boolean :text_requested
      t.boolean :images_requested
      t.boolean :links_requested
      t.boolean :download_completed

      t.timestamps
    end
  end
end
