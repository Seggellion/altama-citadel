class CommodityStubInventory < ActiveRecord::Migration[7.0]
  def change

    create_table :commodity_stubs do |t|
      t.integer :user_id
      t.integer :commodity_id
      t.integer :buy_price
      t.integer :sell_price
      t.boolean :flagged
      t.timestamps
    end

    add_column :commodities, :inventory, :integer, default: 0

    change_column_null :users, :username, false

    create_table :star_bitizen_runs do |t|
      t.integer :user_id
      t.integer :commodity_id
      t.integer :profit, default: 0
      t.integer :scu, default: 0
      t.timestamps
    end

  end
end
