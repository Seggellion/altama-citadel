class Rewards < ActiveRecord::Migration[7.0]
  def change

    create_table :rewards do |t|
      t.string :title
      t.float :amount
    end
  create_table :commodities do |t|
    t.string :symbol
    t.string :name
    t.float :price
    t.timestamps
  end

  create_table :rfa_products do |t|
    t.integer :commodity_id
    t.integer :rfa_id
    t.float :amount
    t.float :market_price
    t.float :selling_price
    
    t.index ['rfa_id', 'commodity_id'], name: 'one_product_per_rfa', unique: true

  
  


    t.timestamps
  end


    remove_column :rfas, :total_fuel
    remove_column :rfas, :total_cost
    remove_column :rfas, :total_price


  end
end
