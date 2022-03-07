class GuildstonesController < ApplicationController
  before_action :set_guildstone, only: %i[ show edit update destroy ]

  # GET /guildstones or /guildstones.json
  def index
    @guildstones = Guildstone.all
  end

  # GET /guildstones/1 or /guildstones/1.json
  def show
    @new_role_nomination = OrgRoleNomination.new
    @org_role = OrgRole.new
    @lvl1_roles = OrgRole.where(guildstone_id: @guildstone.id, role_level:1)
    @lvl2_roles = OrgRole.where(guildstone_id: @guildstone.id, role_level:2)
    @lvl3_roles = OrgRole.where(guildstone_id: @guildstone.id, role_level:3)
    @lvl4_roles = OrgRole.where(guildstone_id: @guildstone.id, role_level:4)
    @lvl5_roles = OrgRole.where(guildstone_id: @guildstone.id, role_level:5)
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


    nomination = OrgRoleNomination.find_by_id(params[:nomination])
    role = OrgRole.find_by_id(nomination.id)
    guildstone = Guildstone.find_by_id(role.guildstone_id)
    @vote = OrgRoleVote.new(org_role_nomination_id: nomination.id, user_id: current_user)

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
