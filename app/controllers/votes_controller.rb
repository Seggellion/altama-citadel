class VotesController < ApplicationController

  before_action :set_vote, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @votes = Vote.all
  end

  def new
    @vote = Vote.new
  end

  def create
    @vote = Vote.new(rule_params)
    @guildstone = Guildstone.first
    @vote.update(guildstone_id: @guildstone.id)
    @vote.update(user_id: current_user.id)
    respond_to do |format|
      if @vote.save
        format.html { redirect_to @vote, notice: "Vote was successfully created." }
        format.json { render :show, status: :created, location: @vote }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vote.destroy
    respond_to do |format|
      format.html { redirect_to votes_url, notice: "Vote was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @vote.update(vote_params)
        format.html { redirect_to @vote, notice: "Vote was successfully updated." }
        format.json { render :show, status: :ok, location: @vote }
      else
        format.html { render :edit, status: :unprocessable_entity, notice: "Unable to update vote" }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_vote
    @vote = Vote.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def vote_params
    params.require(:vote).permit(:user_id, :guildstone_id, :position_id, :rule_id, :position_nomination_id, :feedback)
  end

  


end