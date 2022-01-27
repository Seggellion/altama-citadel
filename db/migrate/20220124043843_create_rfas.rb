class CreateRfas < ActiveRecord::Migration[7.0]
  def change
    create_table :rfas do |t|
      t.string :title
      t.string :rsi_username
      t.string :description
      t.integer :user_id
      t.integer :status_id
      t.integer :location_id
      t.integer :ship_id
      t.integer :priority_id
      t.integer :total_fuel
      t.integer :total_price
      t.integer :total_cost
      t.integer :aec_rewards
      t.integer :user_assigned_id

      t.timestamps
    end
  end
end
