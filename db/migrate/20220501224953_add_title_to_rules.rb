class AddTitleToRules < ActiveRecord::Migration[7.0]
  def change
    add_column :rules, :title, :string
  end
end
