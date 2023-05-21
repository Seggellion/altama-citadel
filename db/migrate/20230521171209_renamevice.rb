class Renamevice < ActiveRecord::Migration[7.0]
  def change
    rename_column :commodities, :vices, :vice
  end
end
