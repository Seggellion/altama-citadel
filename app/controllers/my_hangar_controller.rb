class MyHangarController < ApplicationController
  before_action :set_usership, only: %i[ show edit update destroy ]
  before_action :task_manager
  # GET /userships or /userships.json
  def index
    @userships = Usership.all
    @current_task = @all_tasks.where(name: 'My Hangar').first
  end

def view
@current_task = @all_tasks.where(name: 'My Hangar').first
    @myships = Usership.where(user_id: current_user.id).joins(:ship).order(length: :asc)
    @myships_origin = Usership.where(user_id: current_user.id)
end

def clear_ships
  @myships = Usership.where(user_id: current_user.id, source: "imported")
  @myships.destroy_all
  respond_to do |format|
    format.html { redirect_to my_hangar_add_path, notice: "Records clear." }
    format.json { head :no_content }
  end
end

def all_fleet
  @current_task = @all_tasks.where(name: 'My Hangar').first
  @myships = Usership.where(user_id: current_user.id, show_information:nil)
  @myships.each do |usership|   

    id = usership.ship.code.upcase + SecureRandom.base64.delete('/+=')[0, 14].upcase
    usership.update(show_information:1, fid: id)
  end

# @myships.update_all(show_information: 1, fid: id)

  respond_to do |format|
    format.html { redirect_to my_hangar_manage_path, notice: "Records clear." }
    format.json { head :no_content }
  end
end

def all_fleet_remove
  @myships = Usership.where(user_id: current_user.id, show_information:1)
  @myships.update_all(show_information:nil, fid: nil)

# @myships.update_all(show_information: 1, fid: id)

  respond_to do |format|
    format.html { redirect_to my_hangar_manage_path, notice: "Records clear." }
    format.json { head :no_content }
  end
end

def fleet_view
  org_users = User.where("user_type < ?", 42) 
 # Usership.joins(:user).where(user: { user_id: org_users })  
  org_ships = Usership.where(show_information:1)
  @current_task = @all_tasks.where(name: 'My Hangar').first
  @allships = []
  unless org_ships.blank?    
    org_users.each do | user | 
      org_ships_match = org_ships.where(user_id: user.id)
      @allships = @allships + org_ships_match      
    end
  end
  @allships = Usership.where(:id=>@allships)
  
  @org_ships_sorted_count =  @allships.joins(:ship).group('ships.model').count.sort_by{|e| e[1]}.reverse
 #  @org_ships_sorted_count = Usership.all.joins(:ship).group('ships.model').count
  
end

  # GET /userships/1 or /userships/1.json
  def show
  end

  # GET /userships/new
  def add
    @usership = Usership.new
    @alluserships = Usership.where(user_id: current_user.id)
    @allships = Ship.all
    @current_task = @all_tasks.where(name: 'My Hangar').first
  end

  def manage
    @usership = Usership.new
    @alluserships = Usership.where(user_id: current_user.id)
    @current_task = @all_tasks.where(name: 'My Hangar').first
    @alluserships_models = current_user.ships.group(:id).order(model: :asc)
    #@alluserships_models = Usership.where(user_id: current_user.id).group(:ship_id)
    
    @allships = Ship.all.order(model: :asc)
  end

  # GET /userships/1/edit
  def edit
  end
 
  # POST /userships or /userships.json
  def create
    @usership = Usership.new(usership_params)

    respond_to do |format|
      if @usership.save
        format.html { redirect_to @usership, notice: "Usership was successfully created." }
        format.json { render :show, status: :created, location: @usership }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @usership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /userships/1 or /userships/1.json
  def update

    respond_to do |format|
      if @usership.update(usership_params)
        format.html { redirect_to @usership, notice: "Usership was successfully updated." }
        format.json { render :show, status: :ok, location: @usership }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @usership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /userships/1 or /userships/1.json
  def destroy
    @usership.destroy
    respond_to do |format|
      format.html { redirect_to userships_url, notice: "Usership was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usership
      @usership = Usership.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def usership_params
      params.require(:usership).permit(:ship_name, :year_purchased, :description, :ship, :user_id, :paint)
    end
end
