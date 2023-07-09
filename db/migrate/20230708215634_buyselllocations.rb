class Buyselllocations < ActiveRecord::Migration[7.0]
  def change
    add_column :milk_runs, :buy_location, :string
    add_column :milk_runs, :sell_location, :string
  end
end
