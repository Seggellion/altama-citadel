class Uniquegiveaway < ActiveRecord::Migration[7.0]
  def change
    add_index :giveaway_users, [:user_id, :giveaway_id], unique: true
  end
end
