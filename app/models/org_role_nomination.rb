class OrgRoleNomination < ApplicationRecord

    def total_votes
        OrgRoleVote.where(org_role_nomination_id:self.id).count
    end

end
