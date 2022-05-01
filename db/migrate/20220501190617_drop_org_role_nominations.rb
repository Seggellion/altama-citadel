class DropOrgRoleNominations < ActiveRecord::Migration[7.0]
  def change
    drop_table :org_role_nominations, force: :cascade
  end
end
