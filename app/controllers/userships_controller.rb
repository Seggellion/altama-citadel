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
    json = {
      "name": "Spartan",
      "manufacturer_code": "ANVL",
      "manufacturer_name": "Anvil Aerospace",
      "ship_code": "ANVL_Spartan",
      "ship_name": "Spartan",
      "ship_serial": null,
      "pledge_id": "31119322",
      "pledge_name": "Package - 100i Starter Pack - Free Fly",
      "pledge_date": "2021-08-19",
      "pledge_cost": "$73.50 USD",
      "lti": false,
      "warbond": false
    }.to_json

    @usership = Usership.new
    @usership.from_json(json)
    ##@usership = Usership.new(usership_params)
    ##@usership.update(user_id:current_user.id)
    ##respond_to do |format|
     # if @usership.save
        #flash[:notice] = "Post has been saved successfully."
      if @usership.save 
          format.html { redirect_to request.referrer, notice: "Usership was successfully created." }
          format.json { render :show, status: :created, location: @usership }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @usership.errors, status: :unprocessable_entity }
      end
    ##end
  end

  # PATCH/PUT /userships/1 or /userships/1.json
  def update
    respond_to do |format|
      if @usership.update(usership_params)
      #  format.turbo_stream { render turbo_stream: turbo_stream.update(@usership) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(:userships, partial: "userships/usership_details",
          locals: { usership: @usership })
      end
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
      format.html { redirect_to userships_url, notice: "Usership was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    
  def redirect_cancel
    redirect_to request.referrer if params[:cancel]
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_usership
      @usership = Usership.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def usership_params
      params.require(:usership).permit(:ship_name, :year_purchased, :description, :ship_id, :user_id, :paint, :primary)
    end
end
