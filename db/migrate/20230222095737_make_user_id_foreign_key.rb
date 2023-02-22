class MakeUserIdForeignKey < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :downloads, :users, column: :user_id
  end
end
