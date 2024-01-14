class EventUsersController < ApplicationController
    before_action :set_event_user, only: %i[ show edit update destroy ]
  
    # GET /event_users or /event_users.json
    def index
      @event_users = EventUser.all
    end
  
    # GET /event_users/1 or /event_users/1.json
    def show
    end

    def join
        
        EventUser.create(user_id: current_user.id, event_id: 1)
        EventShip.create(usership_id: current_user.userships.first.id )
        redirect_to root_path
    end

    def leave
      
      event = Event.find_by_id(params[:event_id])
      event_user = EventUser.find_by(user_id: current_user.id, event_id: params[:event_id])
      
      if event_user.event_series_id.present? && event_user.must_join_all?
        
        event_users = EventUser.where(user_id: current_user.id, event_series_id: event.event_series_id)
        event_ships_ids = []
        
        event_users.each do |eventuser|          
            event_ships_ids  << EventShip.find_by(event_id: eventuser.event_id).id
          end


          @event_ships = EventShip.find(event_ships_ids)
          
        @event_ships.each(&:destroy)
        event_users.destroy_all        
      else
        event_ship = EventShip.find_by(event_id: event.id)
        event_ship.destroy
        event_user.destroy
      end


        current_user.take_karma(202)
        current_user.take_fame(202)

        redirect_to root_path
    end
  
    # GET /event_users/new
    def new
      @event_user = EventUser.new
    end
  
    # GET /event_users/1/edit
    def edit
    end
  
    # POST /event_users or /event_users.json
    def create
      params[:event_user][:user_id] = current_user.id
      usership = Usership.find_by_id(event_user_params[:usership_id])
      current_event = Event.find_by_id(event_user_params[:event_id])
      event_series = EventSeries.find_by_id(current_event.event_series_id)
      
      if current_event.event_series_id && event_series&.must_join_all
        Event.where(event_series_id: current_event.event_series_id).each do |event|
          event_user = create_event_user(usership, event)
          create_event_ship(event_user, usership, event)
          update_user_stats
        end
      else
        event_user = create_event_user(usership, current_event)
        create_event_ship(event_user, usership, current_event)
        update_user_stats
      end
    
      redirect_to root_path, notice: "Event user was successfully created."
    end
  
    # PATCH/PUT /event_users/1 or /event_users/1.json
    def update
      respond_to do |format|
        if @event_user.update(event_user_params)
          format.html { redirect_to @event_user, notice: "Event user was successfully updated." }
          format.json { render :show, status: :ok, location: @event_user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event_user.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /event_users/1 or /event_users/1.json
    def destroy
      @event_user.destroy
      respond_to do |format|
        format.html { redirect_to event_users_url, notice: "Event user was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_user
        @event_user = EventUser.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def event_user_params
        params.require(:event_user).permit(:event_id, :user_id, :usership_id)
      end


      def create_event_user(usership, event)
        EventUser.create!(
          event_series_id: event.event_series_id, 
          usership_id: usership.id, 
          event_id: event.id, 
          user_id: current_user.id, 
          ship_fid: usership.fid
        )
      end
      
      def create_event_ship(event_user, usership, event)
        EventShip.create!(
          event_user_id: event_user.id,
          usership_id: usership.id,
          event_id: event.id,
          ship_fid: usership.fid,
          ship_id: usership.ship_id,
          ship_name: usership.ship_name
        )
      end
      
      def update_user_stats
        current_user.give_karma(200)
        current_user.give_fame(200)
      end


  end
  