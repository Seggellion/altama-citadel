class TermStatrtFixed < ActiveRecord::Migration[7.0]
  def change
    remove_column :positions, :term_start
    add_column :positions, :term_start, :datetime
  end
end
