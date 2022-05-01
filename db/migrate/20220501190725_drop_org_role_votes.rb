class DropOrgRoleVotes < ActiveRecord::Migration[7.0]
  def change
    drop_table :org_role_votes, force: :cascade
  end
end
