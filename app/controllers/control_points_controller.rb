class ControlPointsController < ApplicationController
  before_action :set_control_point, only: %i[ show edit update destroy ]

  # GET /events or /events.json
  def index
    @control_points = ControlPoint.all
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @control_point = ControlPoint.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @control_point = ControlPoint.new(control_point_params)
    event = Event.find_by_id(control_point_params[:event_id])
    respond_to do |format|
      if @control_point.save
        format.html { redirect_to conquest_event_path(id: event), notice: "ControlPoint was successfully created." }
        format.json { render :show, status: :created, location: @control_point }
      else
        format.html { redirect_to conquest_event_path(event), status: :unprocessable_entity }
        format.json { render json: @control_point.errors, status: :unprocessable_entity }
      end
    end
  end

  def capture_conquest
    control_point = ControlPoint.find_by_id(params[:id])
    last_record = EventRecord.where(control_point_id: control_point.id).last

    event = Event.find_by_id(control_point.event_id)
    team = Team.find_by_id(last_record.team_id)

    control_point.update(capture_team_id: team.id)
    respond_to do |format|
      format.html { redirect_to conquest_event_path(id: event), notice: "ControlPoint was successfully created." }
    end
  end

  def stop_conquest    
    control_point = ControlPoint.find_by_id(params[:id])
    event = Event.find_by_id(control_point.event_id)
    last_record = EventRecord.where(control_point_id: control_point.id).last
    if last_record
      
      duration = Time.current - last_record.start_time
    last_record.update(end_time: Time.current,duration: duration, action:'stop')


    end

      

    control_point.update(capture_team_id: nil) 
    respond_to do |format|
      format.html { redirect_to conquest_event_path(id: event), notice: "ControlPoint was successfully created." }
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    event = Event.find_by_id(@control_point.event_id)
    respond_to do |format|
      if @control_point.update(control_point_params)
        format.html { redirect_to conquest_event_path(id: event), notice: "ControlPoint was successfully created." }
        format.json { render :show, status: :ok, location: @control_point }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @control_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @control_point.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "ControlPoint was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_control_point
      @control_point = ControlPoint.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def control_point_params
      params.require(:control_point).permit(:title, :event_id, :capture_team_id)
    end
end
