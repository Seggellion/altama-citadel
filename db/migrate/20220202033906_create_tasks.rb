class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :author
      t.string :icon
      t.integer :task_manager_id
      t.timestamps
    end

    create_table :task_managers do |t|
      t.integer :user_id
      t.string :task_id

      t.timestamps
    end

    remove_column :users, :email, :string

  end
end
