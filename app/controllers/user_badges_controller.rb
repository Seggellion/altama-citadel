class UserBadgesController < ApplicationController
    before_action :set_user_badge, only: %i[ show edit update destroy ]

def index
redirect_to badges_path
end

    def create   
      update_complete = false         
          if user_badge_params[:race_id].present?                      
            @all_race_users = DivisionJoin.where(race_id: user_badge_params[:race_id])
            @all_race_users.each do | team|
              
              team.team.all_team_users.each do | user |             
                does_already_exist = UserBadge.find_by(badge_id: user_badge_params[:badge_id], user_id: user.id)
                  
                  if does_already_exist.nil?
                    p 'does not exist!!'
                    @user_badge = UserBadge.create(badge_id: user_badge_params[:badge_id], user_id: user.id)
                    update_complete = true
                  else
                    p 'exists?'
                    update_complete = false
                  end
              end
            end
          else
            does_already_exist = UserBadge.find_by(badge_id: user_badge_params[:badge_id], user_id: user_badge_params[:user_id])
            @user_badge = UserBadge.create(user_badge_params)
            update_complete = true
          end

          

        badge = Badge.find_by_id(user_badge_params[:badge_id])
        
        unless does_already_exist = UserBadge.find_by(badge_id: user_badge_params[:badge_id], user_id: user_badge_params[:user_id])
        respond_to do |format|          
          if update_complete == true   
            format.html { redirect_to badges_path, notice: "Badge was attributed to account" }
            format.json { render :show, status: :created, location: badge }
          else
            format.html { redirect_to badges_path, notice: "Badge unsaved" }
            format.json { render json: @user_badge.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|     
          format.json { render json: @user_badge.errors, status: :unprocessable_entity }
          format.html { redirect_to badges_path, notice: "User already has badge" }
        
        end
      end
    end

  


    def destroy


        @user_badge.destroy
        respond_to do |format|
          format.html { redirect_to badges_url, notice: "You removed badge from account" }
          format.json { head :no_content }
        end
      end

private

def set_user_badge
    
    @user_badge = UserBadge.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_badge_params
    
    params.require(:user_badge).permit(:user_id, :badge_id, :race_id)
  end

end