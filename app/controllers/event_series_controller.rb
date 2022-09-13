class EventSeriesController < ApplicationController
    before_action :set_event_series, only: %i[ show edit update destroy ]
  
    # GET /event_series or /event_series.json
    def index
      @event_series = EventSeries.all
    end
  
    # GET /event_series/1 or /event_series/1.json
    def show
    end

    # GET /event_series/new
    def new
      @event_series = EventSeries.new
    end
  
    # GET /event_series/1/edit
    def edit
    end
  
    # POST /event_series or /event_series.json
    def create

      total_events = 0
      if !params[:event_series][:start_date_9].blank?
        total_events = 10
      elsif !params[:event_series][:start_date_8].blank?
      
      elsif !params[:event_series][:start_date_7].blank?
      
      elsif !params[:event_series][:start_date_1].blank?
        
        total_events = 1
      elsif !params[:event_series][:start_date_0].blank?
        
        total_events = 0
      end



        new_events = [
       #   {params[:event_series][:start_date_0]},
      #    {params[:event_series][:start_date_1]},
       #   {params[:event_series][:start_date_2]}
        ]
        
      @event_series = EventSeries.new(title:event_series_params[:title])
      
      respond_to do |format|
        if @event_series.save

          for i in 0..total_events
byebug
            Event.create(event_series_id: EventSeries.last.id ,title: 'multi-event', 
            maximum_attendees: params[:event_series][:maximum_attendees],
            start_date:params[:event_series]["start_date_#{i}".to_sym])
      
            end

          format.html { redirect_to root_path, notice: "Event user was successfully created." }
          
        else
            format.html { redirect_to root_path, notice: "Error." }
          
        end
      end
    end
  
    # PATCH/PUT /event_series/1 or /event_series/1.json
    def update
      respond_to do |format|
        if @event_series.update(event_series_params)
          format.html { redirect_to @event_series, notice: "Event user was successfully updated." }
          format.json { render :show, status: :ok, location: @event_series }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event_series.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /event_series/1 or /event_series/1.json
    def destroy
      @event_series.destroy
      respond_to do |format|
        format.html { redirect_to event_series_url, notice: "Event user was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_series
        @event_series = EventSeries.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def event_series_params
        params.require(:event_series).permit(:event_id, :title, :maximum_attendees,:start_date_5,
         :description, :start_date_0, :start_date_1, :start_date_2, :start_date_3, :start_date_4
        )
      end
  end
  