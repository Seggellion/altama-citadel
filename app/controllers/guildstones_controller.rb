class GuildstonesController < ApplicationController
  before_action :set_guildstone, only: %i[ show edit update destroy ]
  before_action :task_manager
  

  # GET /guildstones or /guildstones.json
  def index
    @guildstones = Guildstone.all
  end

  # GET /guildstones/1 or /guildstones/1.json
  def show
    @current_task = @all_tasks.where(name: 'Guildstone').first
    window_state_csv = @current_task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
    end
    unless window_state_csv.nil?
      @message_windows = window_state_csv.split(',')
    end
    #@new_role_nomination = OrgRoleNomination.new
    @departments = Department.all
    @department = Department.new
    @categories = Category.all
    @category = Category.new
    @users = User.all
    @rules = Rule.all
    @rule = Rule.new
    @rule_proposal = RuleProposal.new
    @rule_proposals = RuleProposal.all
    @positions = Position.all
    @position_nominations = PositionNomination.all
    
    if @window_states
      @user_position_windows = @window_states.select { |s| s == "UserPositions" }
      @rules_windows = @window_states.select { |s| s == "Rules" }
      @message_windows = @window_states.select { |s| s.include?("message") }
      @guildstone_messages = Message.where(task_id: 'Guildstone')
      
    end
  end

  def apply_role
    role = OrgRole.find_by_id(params[:role])
    guildstone = Guildstone.find_by_id(role.guildstone_id)
    @apply = OrgRoleNomination.new(org_role_id: role.id, user_id: current_user)

    respond_to do |format|
      if @apply.save
        format.html { redirect_to guildstone, notice: "Guildstone was successfully created." }
        format.json { render :show, status: :created, location: guildstone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: guildstone.errors, status: :unprocessable_entity }
      end
    end

  end

  def vote
    guildstone = Guildstone.first

    # voting non-confidence
    if NonConfidence.find_by_id(params[:non_confidence])
      non_confidence = NonConfidence.find_by_id(params[:non_confidence])
      @vote = Vote.new(non_confidence_id: non_confidence.id, position_id: non_confidence.user_position_id, rule_id: non_confidence.rule_id,
         guildstone_id: guildstone.id, user_id: current_user.id, vote:true)
        total_members = User.where("user_type < ?", 100).count
        total_votes = Vote.where(non_confidence_id: non_confidence.id).count
        #remove the two -- for testing only
        consensus = (total_members * 0.66666) - 2
        
      if total_votes > consensus
        if non_confidence.rule_id
          Rule.where(id: non_confidence.rule_id).destroy
        elsif non_confidence.user_position_id
          UserPosition.where(id: non_confidence.user_position_id).destroy
        end
      end
    end

    # voting on rules
    if RuleProposal.find_by_id(params[:rule_proposal])
      rule_proposal = RuleProposal.find_by_id(params[:rule_proposal])
      @vote = Vote.new(rule_proposal_id: rule_proposal.id, position_id: rule_proposal.position_id,  guildstone_id: guildstone.id,
        user_id: current_user.id, vote:true)
        total_members = User.where("user_type < ?", 100).count
        total_votes = Vote.where(rule_proposal_id: rule_proposal.id).count
        #remove the two -- for testing only
        consensus = (total_members * 0.66666) - 2
        
      if total_votes > consensus
        @new_rule = Rule.create(user_id: rule_proposal.proposer_id, guildstone_id: guildstone.id, position_id: rule_proposal.position_id,
          description: rule_proposal.description, title: rule_proposal.title, department_id: rule_proposal.department_id,
          category: rule_proposal.category, code_enforced: rule_proposal.code_enforced
        )
        term_length = @new_rule.term_length_days.to_s + 'd'

         # destroy rule in term_length_days, send user a message that their rule's term has ended.
      Rufus::Scheduler.singleton.in term_length do
        Message.create(user_id: rule_proposal.proposer_id, task_id: "Guildstone", content:"Your rule's term has ended, RuleID: #{@new_rule[:id]}", subject:"Altama Rule Term End")
        @new_rule.destroy
      end
      end
    end

    #voting on position nominations
    if PositionNomination.find_by_id(params[:nomination])
   
    nomination = PositionNomination.find_by_id(params[:nomination])
    @users_user_position_histories = UserPositionHistory.where(user_id: nomination.user.id)
    position = Position.find_by_id(nomination.position_id)
    existing_user_position = UserPosition.where(user_id: nomination.user.id)
    
    @vote = Vote.new(position_nomination_id: nomination.id, guildstone_id: guildstone.id,
    user_id: current_user.id, position_id: position.id, vote:true,  )
    total_members = User.where("user_type < ?", 100).count
    total_votes = Vote.where(position_id: nomination.id).count
    #remove the two -- for testing only
    consensus = (total_members * 0.66666) - 2
    #term_end = Time.now + 3.months
    term_length = position.term_length_days.to_s + 'd'

    if total_votes > consensus && !existing_user_position
     @new_user_position =  UserPosition.create(user_id: nomination.user.id,position_id: position.id, term_length_days: position.term_length_days, 
      department_id: position.department_id, guildstone_id: Guildstone.first.id, nomination_id: nomination.id, title: position.title, description: position.description, compensation: position.compensation)
      @users_user_position_histories.update_all(active: false)
      
      # destroy user_position in term_length_days, send user a message that their term has ended.
      Rufus::Scheduler.singleton.in term_length do
        Message.create(user_id: nomination.user.id, task_id: "Guildstone", content:"Your term has ended, RoleID: #{@new_user_position[:position_id]}", subject:"Altama Posititon Term End")
        @new_user_position.destroy
      end
      
      UserPositionHistory.create(
        user_id: nomination.user.id, position_id: position.id, term_length_days: position.term_length_days, 
        department_id: position.department_id, guildstone_id: Guildstone.first.id,
        nomination_id: nomination.id, title: position.title, description: position.description, compensation: position.compensation, active: true
      )
    elsif total_votes > consensus && existing_user_position
      puts "stuff"
    end
  end
  
    respond_to do |format|
      if @vote.save
        format.html { redirect_to guildstone, notice: "Vote cast." }
        format.json { render :show, status: :created, location: guildstone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: guildstone.errors, status: :unprocessable_entity }
      end
    end
  end

  def unvote
    guildstone = Guildstone.first
    if RuleProposal.find_by_id(params[:rule_proposal])
      rule_proposal = RuleProposal.find_by_id(params[:rule_proposal])
      @vote = Vote.find_by(rule_proposal_id: rule_proposal.id, guildstone_id: guildstone.id,
        user_id: current_user.id)
    end

    if PositionNomination.find_by_id(params[:nomination])
      nomination = PositionNomination.find_by_id(params[:nomination])
      position = Position.find_by_id(nomination.position_id)
      
      @vote = Vote.find_by(position_nomination_id: nomination.id, guildstone_id: guildstone.id,
      user_id: current_user.id)
    end
    respond_to do |format|
      if @vote.destroy
        format.html { redirect_to guildstone, notice: "unvoted." }
        format.json { render :show, status: :created, location: guildstone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: guildstone.errors, status: :unprocessable_entity }
      end
    end
  end


  def guildstone_start_asl
    @window_states =  []
    unless @all_tasks.find_by(name: "Guildstone" ).present?
      @window_states = @window_states + Array[state_name]
    end
    last_message = Message.where(task_id: "Guildstone", user_id: current_user.id).last
    task = @all_tasks.find_by(name: "Guildstone" )
    window_state_csv = task.state
    state_name = "message-Guildstone|"
    
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      message_states = window_state_csv.split('|')
    end  
    
    unless @window_states.include?(state_name)
      if last_message
        @window_states = @window_states + Array[state_name + last_message.id.to_s]
      else 
        @window_states = @window_states + Array[state_name]
      end
    end
    states_string = @window_states.join(',')
    
    task.update(state:states_string)
    redirect_to(request.env['HTTP_REFERER'])
  end

  # GET /guildstones/new
  def new
    @guildstone = Guildstone.new
  end

  # GET /guildstones/1/edit
  def edit
  end

  # POST /guildstones or /guildstones.json
  def create
    @guildstone = Guildstone.new(guildstone_params)

    respond_to do |format|
      if @guildstone.save
        format.html { redirect_to @guildstone, notice: "Guildstone was successfully created." }
        format.json { render :show, status: :created, location: @guildstone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @guildstone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /guildstones/1 or /guildstones/1.json
  def update
    respond_to do |format|
      if @guildstone.update(guildstone_params)
        format.html { redirect_to @guildstone, notice: "Guildstone was successfully updated." }
        format.json { render :show, status: :ok, location: @guildstone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @guildstone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guildstones/1 or /guildstones/1.json
  def destroy
    @guildstone.destroy
    respond_to do |format|
      format.html { redirect_to guildstones_url, notice: "Guildstone was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guildstone

      @guildstone = Guildstone.all.first
    end

    # Only allow a list of trusted parameters through.
    def guildstone_params
      params.require(:guildstone).permit(:charter, :title)
    end
end
