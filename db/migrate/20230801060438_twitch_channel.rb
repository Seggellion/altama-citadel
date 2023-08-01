class TwitchChannel < ActiveRecord::Migration[7.0]
  def change

    add_column :star_bitizen_runs, :twitch_channel, :integer

  end
end
