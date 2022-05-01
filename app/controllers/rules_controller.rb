class RulesController < ApplicationController

  before_action :set_rule, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @rules = Rule.all
  end

  def new
    @rule = Rule.new
  end

  def create
    user_id = current_user
    @rule = Rule.new(rule_params)
    guildstone_id = 1
    respond_to do |format|
      if @rule.save
        format.html { redirect_to @rule, notice: "Rule was successfully created." }
        format.json { render :show, status: :created, location: @rule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to rules_url, notice: "Rule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to @rule, notice: "Rule was successfully updated." }
        format.json { render :show, status: :ok, location: @rule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_rule
    @rule = Rule.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def rule_params
    params.require(:rule).permit(:description, :title)
  end

  

end