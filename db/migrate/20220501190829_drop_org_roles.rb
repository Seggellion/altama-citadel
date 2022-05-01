class DropOrgRoles < ActiveRecord::Migration[7.0]
  def change
    drop_table :org_roles, force: :cascade
  end
end
