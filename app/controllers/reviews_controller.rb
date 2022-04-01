class ReviewsController < ApplicationController
  before_action :set_review, only: %i[edit update destroy ]

def create
  rfa = Rfa.find_by_id(review_params[:rfa_id])
  rating =review_params[:rating].to_i
  if request.path.include? "reviews"
    reviewer = current_user
    reviewee = rfa.user
  else
    reviewer = rfa.user
    reviewee = current_user
  end
  existing_review =  Review.where(rfa_id: rfa.id, user_id: reviewer.id)

  merge_params = review_params.merge(user_id: reviewer.id, reviewee_id: reviewee.id)
  # @review = Review.first_or_initialize(merge_params)
  @review = Review.new(merge_params)

  reviewer.give_karma(rating)
  reviewer.give_fame(rating)
  reviewee.give_karma(rating * 1.5)
  reviewee.give_fame(rating * 1.5)


    respond_to do |format|
      if  existing_review.blank? && @review.save
        if request.path.include? "reviews"
          format.html { redirect_to roadside_assistance_path, notice: "review was successfully created." }
        #  format.html { redirect_to rfa_location_path(location: rfa.location.find_planet.id), notice: "review was successfully created." }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { redirect_to desktop_path, notice: "review was successfully created." }
          format.json { render :show, status: :created, location: @review }
        end
      elsif !existing_review.blank?
        
        existing_review.update(merge_params)
        format.html { redirect_to  rfa_location_path(location: rfa.location.find_planet.id), notice: "review was successfully created." }
      else
        format.html { redirect_to roadside_assistance_path, notice: "review was successfully created." }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

    
    @review.destroy
    respond_to do |format|
      format.html { redirect_to desktop_path, notice: "Removed review" }
      format.json { head :no_content }
    end
  end

  private

  def set_review
    @review = Reward.find(params[:id])
    
  end


def review_params
  params.require(:review).permit(:rating, :rfa_id, :description) 
end


end