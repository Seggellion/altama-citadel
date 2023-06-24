class Milkruns < ActiveRecord::Migration[7.0]
  def change

    create_table :milk_runs do |t|
      t.integer :user_id
      t.integer :usership_id
      t.integer :commodity_id
      t.integer :trade_session_id
      t.integer :buy_commodity_id
      t.integer :sell_commodity_id
      t.integer :sell_commodity_scu
      t.integer :buy_commodity_scu
      t.integer :buy_commodity_price
      t.integer :sell_commodity_price
      t.integer :max_scu
      t.integer :used_scu
      t.integer :profit
      t.boolean :locked
      
      t.timestamps
    end

  end
end
