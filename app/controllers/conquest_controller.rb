class ConquestController < ApplicationController
 # before_action :set_rfa, only: %i[ show edit update destroy ]

  # GET /rfas or /rfas.json
  def index
    @events = Event.where(event_type:1)
    @event = Event.new
  end

  # GET /rfas/1 or /rfas/1.json
  def show
    @event = Event.find_by_id(params[:id]) 
    @control_points = ControlPoint.where(event_id: @event.id)
    @control_point = ControlPoint.new    
    @teams = Team.all.order(team_name: :asc)
    @team = Team.new
    @event_records = EventRecord.where(event_id: @event.id).order(start_time: :desc)
    @event_record = EventRecord.new
  end

  # GET /rfas/new
  def new
    @event = Event.new
  end

  # GET /rfas/1/edit
  def edit
  end

  # POST /rfas or /rfas.json
  def create
    @event = Event.new(event_params)
# binding.break
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rfas/1 or /rfas/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rfas/1 or /rfas/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to rfas_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:title, :description, :rsi_username, :status_id, 
      :location_id, :ship_id, :priority_id, :total_fuel, :total_price, :total_cost, 
      :aec_rewards, :user_assigned_id)      
    end
end
