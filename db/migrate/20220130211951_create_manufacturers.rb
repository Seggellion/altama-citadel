class CreateManufacturers < ActiveRecord::Migration[7.0]
  def change
    create_table :manufacturers do |t|
      t.string :name
      t.string :description
      t.string :origin_location

      t.timestamps
    end
    rename_column :ships, :make_id, :manufacturer_id
  end
end
