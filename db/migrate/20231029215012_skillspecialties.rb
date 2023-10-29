class Skillspecialties < ActiveRecord::Migration[7.0]
  def change
    add_column :user_skills, :specialty, :string, default: 'none'
  end
end
