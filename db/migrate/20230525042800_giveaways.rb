class Giveaways < ActiveRecord::Migration[7.0]
  def change

    create_table :giveaways do |t|
      t.integer :bot_id
      t.string :channel
      t.string :title
      t.string :description
      t.string :winner
      t.datetime :draw_date
      t.timestamps
    end

    create_table :giveaway_users do |t|
      t.integer :user_id
      t.integer :giveaway_id
      t.timestamps
    end

    create_table :bots do |t|
      t.string :channel
      t.string :bot_name
      t.boolean :bot_online
      t.string :disabled_functions
      t.timestamps
    end


  end
end
