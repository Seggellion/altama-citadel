class OrgRoleVote < ActiveRecord::Migration[7.0]
  def change
    add_column :org_role_votes, :org_role_id, :integer
  end
end
