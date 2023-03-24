class Article < ActiveRecord::Migration[7.0]
  def change

    create_table :articles do |t|
      t.string :article_type
      t.integer :user_id
      t.integer :editor_id
      t.integer :reference_id
      t.integer :location_id
      t.string :featured_image
      t.string :thumbnail_image
      t.string :featured_media
      t.string :introduction
      t.string :content
      t.string :title
      t.datetime :last_updated
      t.timestamps
    end

    change_column :locations, :name, :string, unique: true


  end
end
