class Event < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :capture_limit, :float
    add_column :event_records, :action, :string
  end
end
