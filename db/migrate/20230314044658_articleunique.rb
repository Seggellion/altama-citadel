class Articleunique < ActiveRecord::Migration[7.0]
  def change

    change_column :articles, :title, :string, unique: true
    add_column :locations, :location_chart, :string
    add_column :rfas, :rfa_type, :string
    add_column :articles, :reference_type, :string
    add_column :articles, :reference_date_01, :datetime
    add_column :articles, :reference_date_02, :datetime
    change_column :locations, :parent, :string
    change_column :locations, :location_type, :string
    change_column :locations, :system, :string
    rename_column :commodities, :price, :sell
    add_column :commodities, :buy, :float
    add_column :commodities, :refreshPerMinute, :integer
    add_column :commodities, :maxInventory, :integer

  end
end
