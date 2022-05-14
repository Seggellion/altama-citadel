class CreatePositionNominations < ActiveRecord::Migration[7.0]
  def change
    create_table :position_nominations do |t|
      t.integer :position_id
      t.integer :nominee_id
      t.string :campaign_description
      t.text :resume
      t.integer :nominator_id
      t.integer :guildstone_id
      t.timestamps
    end
  end
end
