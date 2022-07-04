class ChangeUserPositionHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :user_position_histories, :term_length_days, :integer
  end
end
