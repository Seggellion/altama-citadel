class AddColumnsToRules < ActiveRecord::Migration[7.0]
  def change
    add_column :rules, :department_id, :integer
    add_column :rules, :category, :string
    add_column :rules, :code_enforced, :boolean
  end
end
