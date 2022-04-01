class ChangeColumnDefaultUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default(
      :users,
      :user_type,
      from: nil,
      to: 100
    )
  end
end
