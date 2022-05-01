class ChangeRulesTermLengthDays < ActiveRecord::Migration[7.0]
  def change
    change_column_default :rules, :term_length_days, 185
  end
end
