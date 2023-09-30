# Create ForumCategories
class Forum < ActiveRecord::Migration[7.0]
  def change

    create_table :forum_categories do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :forum_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :forum_category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false

      t.timestamps
    end

    create_table :forum_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :forum_post, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

  end
end
