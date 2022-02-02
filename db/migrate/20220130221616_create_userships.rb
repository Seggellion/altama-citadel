class CreateUserships < ActiveRecord::Migration[7.0]
  def change
    create_table :userships do |t|
      t.string :ship_name
      t.string :ship_image
      t.integer :year_purchased
      t.string :description
      t.integer :ship_id
      t.integer :user_id
      t.boolean :show_information
      t.boolean :primary
      t.boolean :fleetship
      t.string :paint

      t.timestamps
    end

    add_column :ships, :year_introduced, :integer
    add_column :ships, :ship_image_primary, :string
    add_column :ships, :ship_image_secondary, :string
    add_column :manufacturers, :logo, :string
  end
end
