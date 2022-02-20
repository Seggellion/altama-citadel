class StarfarerImage < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :starfarer_image, :string
    change_column :locations, :name, :string, :unique => true
  end
end
