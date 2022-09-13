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
        event_user = EventUser.find_by(user_id: current_user.id, event_id: params[:event_id])
        event_ship = EventShip.find_by(event_user_id:event_user.id)
        event_user.destroy
        event_ship.destroy
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
      @event_user = EventUser.new(event_user_params)
    usership = Usership.find_by_id(event_user_params[:usership_id])
      respond_to do |format|
        if @event_user.save

            EventShip.create(event_user_id: EventUser.last.id,
             usership_id: usership.id,
             event_id: event_user_params[:event_id],
             ship_id: usership.ship_id,
             ship_name: usership.ship_name )
          format.html { redirect_to root_path, notice: "Event user was successfully created." }
          
        else
            format.html { redirect_to root_path, notice: "Error." }
          
        end
      end
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
  end
  