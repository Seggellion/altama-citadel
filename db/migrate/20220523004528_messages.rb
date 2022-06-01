class Messages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.integer :sender_id
      t.string :task_id
      t.text :content
      t.boolean :read, :default => false
      t.string :subject
      t.timestamps
    end

    add_column :position_nominations, :approved, :boolean
  end
end
