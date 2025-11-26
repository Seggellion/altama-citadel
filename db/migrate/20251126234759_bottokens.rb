class Bottokens < ActiveRecord::Migration[7.0]
  def change
    change_table :bots do |t|
      t.string     :twitch_channel_id
      t.text     :twitch_access_token
      t.text     :twitch_refresh_token
      t.integer  :twitch_expires_in
      t.datetime :twitch_token_updated_at
    end
  end
end
