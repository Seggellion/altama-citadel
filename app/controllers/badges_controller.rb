class BadgesController < ApplicationController
  before_action :set_badge, only: %i[ show edit update destroy ]

  # GET /badges or /badges.json
  def index
    @badges = Badge.all
    @badge = Badge.new
    @user_badge = UserBadge.new
    @altama_users = User.where.not(org_title: [nil, ""])
    
  end

  # GET /badges/1 or /badges/1.json
  def show
  end

  def all_badges
    
  end

  def my_badges
    @my_badges = UserBadge.where(user_id: current_user.id)
    ribbons = Badge.where(badge_type: 'Ribbon')
    flight_badges = Badge.where(badge_type: 'Flight Badge')
    @my_ribbons = @my_badges.where(:badge_id => ribbons )
    @flight_badges = @my_badges.where(:badge_id => flight_badges )
  end

  # GET /badges/new
  def new
    @badge = Badge.new
  end

  # GET /badges/1/edit
  def edit
  end

  # POST /badges or /badges.json
  def create
    @badge = Badge.new(badge_params)

    respond_to do |format|
      if @badge.save
        format.html { redirect_to @badge, notice: "Badge was successfully created." }
        format.json { render :index, status: :created, location: @badge }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /badges/1 or /badges/1.json
  def update
    respond_to do |format|
      if @badge.update(badge_params)
        format.html { redirect_to @badge, notice: "Badge was successfully updated." }
        format.json { render :show, status: :ok, location: @badge }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /badges/1 or /badges/1.json
  def destroy
    @badge.destroy
    respond_to do |format|
      format.html { redirect_to badges_url, notice: "Badge was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge
      @badge = Badge.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def badge_params
      params.require(:badge).permit(:badge_description, :badge_image, :badge_title, :badge_color, :badge_type, :badge_name)
    end
end
