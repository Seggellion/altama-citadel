class EventTeamsController < ApplicationController
  before_action :set_event_team, only: %i[ show edit update destroy ]

  # GET /event_teams or /event_teams.json
  def index
    @event_teams = EventTeam.all
  end

  # GET /event_teams/1 or /event_teams/1.json
  def show
  end

  # GET /event_teams/new
  def new
    @event_team = EventTeam.new
  end

  # GET /event_teams/1/edit
  def edit
  end

  # POST /event_teams or /event_teams.json
  def create
    @event_team = EventTeam.new(event_team_params)

    respond_to do |format|
      if @event_team.save
        format.html { redirect_to @event_team, notice: "Event team was successfully created." }
        format.json { render :show, status: :created, location: @event_team }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_teams/1 or /event_teams/1.json
  def update
    respond_to do |format|
      if @event_team.update(event_team_params)
        format.html { redirect_to @event_team, notice: "Event team was successfully updated." }
        format.json { render :show, status: :ok, location: @event_team }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event_team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_teams/1 or /event_teams/1.json
  def destroy
    @event_team.destroy
    respond_to do |format|
      format.html { redirect_to event_teams_url, notice: "Event team was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_team
      @event_team = EventTeam.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_team_params
      params.require(:event_team).permit(:event_id, :team_id)
    end
end
