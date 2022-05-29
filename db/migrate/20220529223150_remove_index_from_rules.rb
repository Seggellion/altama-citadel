class RemoveIndexFromRules < ActiveRecord::Migration[7.0]
  def change
    remove_index :rules, name: "index_rules_on_category"
  end
end
