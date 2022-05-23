class Messages < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :sender_id
      t.integer :task_id
      t.string :content
      t.string :subject
      t.timestamps
    end
  end
end
