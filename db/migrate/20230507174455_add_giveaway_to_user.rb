class AddGiveawayToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :giveaway_send, :boolean
  end
end
