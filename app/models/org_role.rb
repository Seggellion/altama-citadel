class OrgRole < ApplicationRecord
    def nominations
        OrgRoleNomination.where(org_role_id: self.id)
    end
end
