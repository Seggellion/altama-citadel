class Discorduser < ActiveRecord::Migration[7.0]
  def change
    create_table :discord_users do |t|
      t.string :username, unique: true, null: false
      t.string :discord_id
      t.string :role
    end
    rename_column :rsi_users, :name, :username
    add_column :tasks, :state, :string
    add_column :users, :error, :string
  end
end
