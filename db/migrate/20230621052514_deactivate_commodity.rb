class DeactivateCommodity < ActiveRecord::Migration[7.0]
  def change

    add_column :commodities, :active, :boolean

  end
end
