class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :title
      t.integer :owner_id
      t.datetime :start_date
      t.integer :tournament_id
      t.string :description
      t.integer :event_type

      t.timestamps
    end
  end
end
