class GuildstonesController < ApplicationController
  before_action :set_guildstone, only: %i[ show edit update destroy ]
  before_action :task_manager

  # GET /guildstones or /guildstones.json
  def index
    @guildstones = Guildstone.all
  end

  # GET /guildstones/1 or /guildstones/1.json
  def show
    
    window_state_csv = @all_tasks.where(name: 'Guildstone').first.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
    end

    #@new_role_nomination = OrgRoleNomination.new
    @departments = Department.all
    @department = Department.new
    @users = User.all
    @positions = Position.all
    @position_nominations = PositionNomination.all
    @user_position_windows = @window_states.select { |s| s == "UserPositions" }
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
    nomination = PositionNomination.find_by_id(params[:nomination])
    position = Position.find_by_id(nomination.position_id)
    guildstone = Guildstone.first
    @vote = Vote.new(position_nomination_id: nomination.id, guildstone_id: guildstone.id,
    user_id: current_user.id, position_id: position.id, vote:true )
    total_members = User.where("user_type < ?", 100).count
    total_votes = Vote.where(position_id: nomination.id).count
    #remove the two -- for testing only
    consensus = (total_members * 0.66666) - 2
    term_end = Time.now + 3.months
  
    if total_votes > consensus
      UserPosition.create(user_id: nomination.user.id,position_id: position.id, term_end: term_end, 
      department_id: position.department_id, guildstone_id: Guildstone.first.id, nomination_id: nomination.id)
      UserPositionHistory.create(
        user_id: nomination.user.id, position_id: position.id, term_end: term_end, 
        department_id: position.department_id, guildstone_id: Guildstone.first.id,
        nomination_id: nomination.id, active: true
      )
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
    nomination = PositionNomination.find_by_id(params[:nomination])
    position = Position.find_by_id(nomination.position_id)
    guildstone = Guildstone.first
    @vote = Vote.find_by(position_nomination_id: nomination.id, guildstone_id: guildstone.id,
    user_id: current_user.id)
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
