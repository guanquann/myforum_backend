class CreatePostThreads < ActiveRecord::Migration[7.0]
  def change
    create_table :post_threads do |t|
      t.string :title
      t.string :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
