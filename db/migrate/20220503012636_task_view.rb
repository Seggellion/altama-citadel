class TaskView < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :view, :string
  end
end
