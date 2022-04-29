class EventRecordsController < ApplicationController
  before_action :set_event_record, only: %i[ show edit update destroy ]

  # GET /event_records or /event_records.json
  def index
    @event_records = EventRecord.all
  end

  # GET /event_records/1 or /event_records/1.json
  def show
  end

  # GET /event_records/new
  def new
    @event_record = EventRecord.new
  end

  # GET /event_records/1/edit
  def edit
  end

def clear_control_points
  control_point = ControlPoint.find_by_id(params[:id])
  event = Event.find_by_id(control_point.event_id)
  all_records = EventRecord.where(control_point_id: control_point.id)
  all_records.destroy_all
  respond_to do |format|
  format.html { redirect_to conquest_event_path(id: event), notice: "Event Record was successfully Cleared." }
  end
end

  # POST /event_records or /event_records.json
  def create
    
    @event_record = EventRecord.new(event_record_params)

    
    event = Event.find_by_id(event_record_params[:event_id])
    last_record = EventRecord.where(event_id: event.id, control_point_id: event_record_params[:control_point_id]).last
    if last_record
      duration = Time.current - last_record.start_time
      
      last_record.update(end_time: Time.current, duration: duration)
      
    end
    
@event_record.update(event_type: event.event_type, start_time: Time.current)
control_point = ControlPoint.find_by_id(event_record_params[:control_point_id])
control_point.update(capture_team_id: nil) 
    respond_to do |format|
      if @event_record.save
        if current_user
        format.html { redirect_to conquest_event_path(id: event), notice: "Event Record was successfully created." }
        else
          format.html { redirect_to staff_edit_conquest_path(event), notice: "Event Record was successfully created." }
        end
        format.json { render :show, status: :created, location: @event_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_records/1 or /event_records/1.json
  def update
    respond_to do |format|
      if @event_record.update(event_record_params)
        format.html { redirect_to @event_record, notice: "Event record was successfully updated." }
        format.json { render :show, status: :ok, location: @event_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_records/1 or /event_records/1.json
  def destroy
    @event_record.destroy
    respond_to do |format|
      format.html { redirect_to event_records_url, notice: "Event record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_record
      @event_record = EventRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_record_params
      params.require(:event_record).permit(:event_type, :event_id, :start_time, :end_time, :duration, :team_id, :control_point_id, :points, :rank_placement)
    end
end
