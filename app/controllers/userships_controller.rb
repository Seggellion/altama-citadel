class UsershipsController < ApplicationController
  before_action :set_usership, only: %i[ show edit update destroy ]
  include ActionView::Helpers::UrlHelper

  before_action :redirect_cancel, only: [:create, :update]


  # GET /userships or /userships.json
  def index
    @userships = Usership.all
  end

  # GET /userships/1 or /userships/1.json
  def show
  end

  # GET /userships/new
  def new
    @usership = Usership.new
  end

  # GET /userships/1/edit
  def edit
  end

  # POST /userships or /userships.json
  def create
    @usership = Usership.new(usership_params)
    @usership.update(user_id:current_user.id)
    respond_to do |format|
     # if @usership.save
        #flash[:notice] = "Post has been saved successfully."
      if @usership.save 
        format.html { redirect_to request.referrer, notice: "Usership was successfully created." }
        format.json { render :show, status: :created, location: @usership }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @usership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /userships/1 or /userships/1.json
  def update
    
    
    usership = Usership.find_by_id(params[:id])
  #  usership_params[:fid] = usership.fid_processor(usership_params[:fid_01],usership_params[:fid_02])
  #param_1 = usership_params[:fid_01]
  
  param_1 = params[:usership][:fid_01].to_s
  param_2 =params[:usership][:fid_02].to_s
  
   
    
    respond_to do |format|
      if usership_params[:primary] == "1"
        primary_userships = Usership.find_by(user_id: current_user.id, primary: 1)
        primary_userships.update(primary:0)
      end
      if usership_params[:show_information] == "0"
        @usership.update(usership_params.except(:fid_01, :fid_02).merge(show_information:nil, fid: nil))
        return
      end

      if @usership.update(usership_params.except(:fid_01, :fid_02).merge(fid: usership.fid_processor(param_1,param_2)))
        
      #  format.turbo_stream { render turbo_stream: turbo_stream.update(@usership) }
      #format.turbo_stream do
      #  render turbo_stream: turbo_stream.append(:userships, partial: "userships/usership_details",
      #    locals: { usership: @usership })
      #end

    # format.turbo_stream
      #  format.html { redirect_to @usership, notice: "Usership was successfully updated." }
      #  format.json { render :show, status: :ok, location: @usership }
     # render partial: 'usership'
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
      format.html { redirect_to my_hangar_manage_path, notice: "Usership was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    
  def redirect_cancel
    redirect_to request.referrer if params[:cancel]
  end
    
    def set_usership
      @usership = Usership.find(params[:id])
    end

    
    def usership_params      
      params.require(:usership).permit(:user_id, :ship_name, :ship_serial, :pledge_id, :show_information,
      :pledge_name, :pledge_date, :lti, :warbond, :year_purchased, :description, :paint, :primary, :fid, :fid_01,:fid_02)
    end
end
