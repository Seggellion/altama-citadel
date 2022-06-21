class ChangeUserPositionsAgain < ActiveRecord::Migration[7.0]
  def change
    remove_column :user_positions, :term_length_days
    add_column :user_positions, :term_length_days, :integer
  end
end
