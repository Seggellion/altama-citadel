class CreateOrgRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :org_roles do |t|
      t.string :description
      t.string :title, unique: true
      t.integer :guildstone_id
      t.integer :role_level
      t.integer :org_role_owner

      t.timestamps
    end
    create_table :org_role_nominations do |t|
      t.string :description
      t.integer :guildstone_id
      t.integer :user_id
      t.integer :org_role_id
      t.datetime :expiry_date

      t.timestamps
    end
    create_table :org_role_votes do |t|

      t.integer :guildstone_id
      t.integer :user_id
      t.integer :org_role_nomination_id

      t.timestamps
    end

    create_table :rsi_users do |t|
      t.string :name, unique: true, null: false
      t.string :title
      t.string :link
    end
    
  end
end
