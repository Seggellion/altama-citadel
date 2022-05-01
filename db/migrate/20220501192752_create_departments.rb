class CreateDepartments < ActiveRecord::Migration[7.0]
  def change
    create_table :departments do |t|
      t.string :title
      t.string :description
      t.integer :guildstone_id
      t.integer :parent_department_id
      

      t.timestamps
    end
  end
end
