class NonConfidencesController < ApplicationController
  before_action :set_non_confidence, only: %i[ show edit update destroy ]

  # GET /non_confidences or /non_confidences.json
  def index
    @non_confidences = NonConfidence.all
  end

  # GET /non_confidences/1 or /non_confidences/1.json
  def show
  end

  # GET /non_confidences/new
  def new
    @non_confidence = NonConfidence.new
  end

  # GET /non_confidences/1/edit
  def edit
  end

  # POST /non_confidences or /non_confidences.json
  def create
    @non_confidence = NonConfidence.new(non_confidence_params)

    respond_to do |format|
      if @non_confidence.save
        format.html { redirect_to guildstones_url, notice: "Non confidence was successfully created." }
        format.json { render :show, status: :created, location: @non_confidence }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @non_confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /non_confidences/1 or /non_confidences/1.json
  def update
    respond_to do |format|
      if @non_confidence.update(non_confidence_params)
        format.html { redirect_to guildstones_url, notice: "Non confidence was successfully updated." }
        format.json { render :show, status: :ok, location: @non_confidence }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @non_confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /non_confidences/1 or /non_confidences/1.json
  def destroy
    @non_confidence.destroy
    respond_to do |format|
      format.html { redirect_to guildstones_url, notice: "Non confidence was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_non_confidence
      @non_confidence = NonConfidence.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def non_confidence_params
      params.require(:non_confidence).permit(:guildstone_id, :user_position_id, :rule_id, :originator_id)
    end
end
