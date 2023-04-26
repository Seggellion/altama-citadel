class Traderundelta < ActiveRecord::Migration[7.0]
  def change
    add_column :trade_runs, :delta, :integer
  end
end
