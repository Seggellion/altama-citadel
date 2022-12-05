class EventOpen < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :open, :boolean
  end
end
