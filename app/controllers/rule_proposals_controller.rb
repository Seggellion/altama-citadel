class RuleProposalsController < ApplicationController
  before_action :set_rule_proposal, only: %i[ show edit update destroy ]

  # GET /rule_proposals or /rule_proposals.json
  def index
    @rule_proposals = RuleProposal.all
  end

  # GET /rule_proposals/1 or /rule_proposals/1.json
  def show
  end

  # GET /rule_proposals/new
  def new
    @rule_proposal = RuleProposal.new
  end

  # GET /rule_proposals/1/edit
  def edit
  end

  # POST /rule_proposals or /rule_proposals.json
  def create
    @rule_proposal = RuleProposal.new(rule_proposal_params)
    @guildstone = Guildstone.first
    @rule_proposal.update(guildstone_id: @guildstone.id)
    @rule_proposal.update(proposer_id: current_user.id)
    respond_to do |format|
      if @rule_proposal.save
        format.html { redirect_to @guildstone, notice: "Rule proposal was successfully created." }
        format.json { render :show, status: :created, location: @rule_proposal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rule_proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rule_proposals/1 or /rule_proposals/1.json
  def update
    respond_to do |format|
      if @rule_proposal.update(rule_proposal_params)
        format.html { redirect_to @rule_proposal, notice: "Rule proposal was successfully updated." }
        format.json { render :show, status: :ok, location: @rule_proposal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rule_proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rule_proposals/1 or /rule_proposals/1.json
  def destroy
    @rule_proposal.destroy
    respond_to do |format|
      format.html { redirect_to rule_proposals_url, notice: "Rule proposal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule_proposal
      @rule_proposal = RuleProposal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rule_proposal_params
      params.require(:rule_proposal).permit(:proposer_id, :guildstone_id, :description, :title, :category, :department_id, :position_id)
    end
end
