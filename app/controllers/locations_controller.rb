class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]
  before_action :task_manager
  # GET /locations or /locations.json
  def index
    @locations = Location.all 
      
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    
    
    @location = Location.new(location_params)
    if Location.all.exists?      
    @location.update(system: Location.last.id + 1)
    end

if main_parent = Location.find_by_id(location_params[:parent])
  @location.update(system: main_parent.id)
end




    respond_to do |format|
      if @location.save
        format.html { redirect_to desktop_path, notice: "Location created." }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location was successfully updated." }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: "Location was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.require(:location).permit(:name, :location_type, :parent, :trade_port, 
      :image, :starfarer_image, :classification, :system, :habitable, :affiliation,
       :ocean_color, :surface_color, :ammenities_rearm, :ammenities_repair, :ammenities_fuel, :trade_terminal)
    end
end
