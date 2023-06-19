class Guildstonetermstart < ActiveRecord::Migration[7.0]
  def change
    add_column :trade_runs, :type, :string
    add_column :positions, :term_start, :string
  end
end
