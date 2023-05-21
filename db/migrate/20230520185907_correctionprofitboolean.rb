class Correctionprofitboolean < ActiveRecord::Migration[7.0]
  def change
    remove_column :trade_runs, :profit
    add_column :trade_runs, :profit, :integer
  end
end
