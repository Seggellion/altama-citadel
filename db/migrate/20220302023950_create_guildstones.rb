class CreateGuildstones < ActiveRecord::Migration[7.0]
  def change
    create_table :guildstones do |t|
      t.string :charter
      t.string :title

      t.timestamps
    end
  end
end
