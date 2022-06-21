class UpdateNonConfidences < ActiveRecord::Migration[7.0]
  def change
    add_column :non_confidences, :guildstone_id, :integer
    add_column :non_confidences, :user_position_id, :integer
    add_column :non_confidences, :rule_id, :integer
    add_column :non_confidences, :originator_id, :integer
  end
end
