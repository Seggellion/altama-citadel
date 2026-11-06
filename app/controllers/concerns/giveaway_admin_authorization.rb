# Giveaway and bot management is limited to logged-in administrators (user_type 0). Before this, these controllers
# had no authentication at all.
module GiveawayAdminAuthorization
  extend ActiveSupport::Concern

  private

  def require_giveaway_admin
    return if current_user&.isAdmin?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "You are not authorized to manage giveaways.", status: :see_other }
      format.any { head :forbidden }
    end
  end
end
