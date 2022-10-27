class EventsController < ApplicationController
  before_action :set_event, only: %i[ show edit update destroy ]
  before_action :task_manager

  # GET /events or /events.json
  def index
    @events = Event.all
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)
    staff_code =  (0...5).map { ('a'..'z').to_a[rand(26)] }.join
    @current_task = @all_tasks.find_by(name: "Conquest" )
    @event.update(owner_id:current_user.id)
    @event.update(staff_code:staff_code)

    respond_to do |format|
      if @event.save
        unless @current_task.nil?
        format.html { redirect_to conquest_event_path(id: @event), notice: "Event was successfully created." }
        else
          format.html { redirect_to root_path, notice: "Event created." }
        end
        format.json { render :show, status: :created, location: @event }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to root_path, notice: "Event updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    
    @event.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Event was successfully destroyed." }
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
      params.require(:event).permit(:title, :owner_id, :start_date, :capture_limit, :tournament_id,
       :description, :event_type, :keyword_required, :maximum_attendees)
    end
end
