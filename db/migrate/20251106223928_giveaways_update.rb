class GiveawaysUpdate < ActiveRecord::Migration[7.0]
  def change
    add_column :giveaways, :mode, :string, default: 'single'
    add_column :giveaways, :cost, :integer, default: 0
    add_column :giveaways, :command_name, :string
    add_column :giveaway_users, :tickets, :integer, default: 1
  end
end
