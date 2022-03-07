class UsershipsController < ApplicationController
  before_action :set_usership, only: %i[ show edit update destroy ]

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
      if @usership.save
        format.html { redirect_to my_hangar_add_path, notice: "Usership was successfully created." }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_usership
      @usership = Usership.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def usership_params
      params.require(:usership).permit(:ship_name, :year_purchased, :description, :ship_id, :user_id, :paint)
    end
end
