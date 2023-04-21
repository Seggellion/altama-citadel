class Traderuns < ActiveRecord::Migration[7.0]
  def change

    create_table :trade_sessions do |t|    
      t.boolean :locked
      t.integer  :profit_vector_pilots
      t.integer  :profit_vector_security
      t.integer  :profit_vector_corporation
      t.boolean :payout_complete
      t.timestamps
    end

    create_table :trade_session_users do |t|
      t.string :username
      t.string :ships_used
      t.integer :tradesession_id
      t.integer  :user_id
      t.integer :pay_amount
      t.integer :transaction_id
      t.timestamps
    end

    create_table :trade_runs do |t|
      t.integer :tradesession_id
      t.string :username
      t.string :ship
      t.integer :usership_id
      t.boolean :split
      t.integer :commodity_id
      t.integer :scu
      t.boolean :locked
      t.string :buy_location
      t.string :sell_location
      t.float :buy_price
      t.float :sell_price
      t.boolean :payout_complete
      t.datetime :last_updated
      t.timestamps
    end

    create_table :trade_run_splits do |t|
      t.integer :traderun_id
      t.integer :commodity_id
      t.integer :scu
      t.float :buy_price
      t.float :sell_price
      t.timestamps
    end



  end
end
