class ChangeUserPositions < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_positions, :term_end, :term_length_days
  end
end
