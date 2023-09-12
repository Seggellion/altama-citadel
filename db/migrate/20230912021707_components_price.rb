class ComponentsPrice < ActiveRecord::Migration[7.0]
  def change
    add_column :ship_components, :component_description, :string
    add_column :ship_components, :component_price, :integer

    remove_column :usership_components, :damaged
    add_column :usership_components, :health, :integer, default: 100
  end
end
