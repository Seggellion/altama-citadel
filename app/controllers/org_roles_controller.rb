class OrgRolesController < ApplicationController
  before_action :set_org_role, only: %i[ show edit update destroy ]

  # GET /org_roles or /org_roles.json
  def index
    @org_roles = OrgRole.all
  end

  # GET /org_roles/1 or /org_roles/1.json
  def show
  end

  # GET /org_roles/new
  def new
    @org_role = OrgRole.new
  end

  # GET /org_roles/1/edit
  def edit
  end

  # POST /org_roles or /org_roles.json
  def create
    @org_role = OrgRole.new(org_role_params)

    respond_to do |format|
      if @org_role.save
        # format.html { redirect_to @org_role, notice: "Org role was successfully created." }
        format.html { redirect_to guildstone_path(0), notice: "Org role was successfully created." }
        format.json { render :show, status: :created, location: @org_role }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @org_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /org_roles/1 or /org_roles/1.json
  def update
    respond_to do |format|
      if @org_role.update(org_role_params)
        format.html { redirect_to @org_role, notice: "Org role was successfully updated." }
        format.json { render :show, status: :ok, location: @org_role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @org_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /org_roles/1 or /org_roles/1.json
  def destroy
    @org_role.destroy
    respond_to do |format|
      format.html { redirect_to org_roles_url, notice: "Org role was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_org_role
      @org_role = OrgRole.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def org_role_params
      params.require(:org_role).permit(:title, :role_level, :description, :guildstone_id, :org_role_owner)
    end
end
