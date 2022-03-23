class RfasController < ApplicationController
  before_action :set_rfa, only: %i[edit update destroy ]

  # GET /rfas or /rfas.json
  def index
    @rfas = Rfa.where(status_id:1)
    @rfas += Rfa.where(status_id:0)
    @rfas += Rfa.where(status_id:2)
    @rfa_hold = Rfa.where(status_id:3)
    @rfa_solved = Rfa.where(status_id:4)
    @rfa_unassigned = Rfa.where(status_id:0)
    @rfa_mine = Rfa.where(user_assigned_id: current_user.id)
    
  end

  # GET /rfas/1 or /rfas/1.json


  # GET /rfas/new
  def new
    @rfa = Rfa.new
  end

  # GET /rfas/1/edit
  def edit
    
    @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  end

  # POST /rfas or /rfas.json
  def create
    @rfa = Rfa.new(rfa_params)
    @location = Location.find_by_id(@rfa.location_id)
  
    Discord::Notifier.message('Request for assistance at:' + @location.name)

    respond_to do |format|
      if @rfa.save
        format.html { redirect_to rfa_location_path(location: @location), notice: "Rfa was successfully created." }
        #format.json { render :show, status: :created, location: @rfa }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rfas/1 or /rfas/1.json
  def update
    user = User.find_by_id(@rfa.user_id)
    # Discord::Notifier.message('!update user: <@'+ user.uid + '>' )
    status = Rfa.get_status(params[:rfa][:status_id].to_i) 
    Discord::Notifier.message('!update ,'+ user.uid + ',' + status)
  #  assigned_user = User.find_by_id(rfa_params[:user_assigned_id])
  merge_params = rfa_params
  if rfa_params[:user_assigned_id].blank?
    merge_params = rfa_params.merge(status_id: 0)
  end
    

    respond_to do |format|
      if @rfa.update(merge_params)
         #format.turbo_stream { render turbo_stream: turbo_stream.update(@rfa) }
       format.turbo_stream
       
      #  format.turbo_stream { render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@rfa)}_item") }

       # format.turbo_stream do
       #   render turbo_stream: turbo_stream.replace(@rfa, partial: 'web/rfa-status')
      # end
        format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa was successfully updated." }
      else
        
        format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa must be assigned to" }
        
        # format.html { render :edit, status: :unprocessable_entity }
        
        #format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rfas/1 or /rfas/1.json
  def destroy
    @rfa.destroy
    respond_to do |format|
      format.html { redirect_to rfas_url, notice: "Rfa was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rfa
      @rfa = Rfa.find(params[:id])
      @users = User.all
    end

    # Only allow a list of trusted parameters through.
    def rfa_params      
      params.require(:rfa).permit(:title, :description, :rsi_username, :status_id, 
      :location_id, :ship_id, :priority_id, :total_fuel, :total_price, :total_cost, 
      :aec_rewards, :user_assigned_id, :user_id)      
    end
end
