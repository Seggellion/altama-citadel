class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[ show edit update destroy ]

  def allDepartments
  end

  def show
  end

  def index
    @departments = Department.all
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)
    @guildstone = Guildstone.first
    @department.update(guildstone_id: @guildstone.id)
    respond_to do |format|
      if @department.save
        redirect_to(request.env['HTTP_REFERER'])
        
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @department.destroy
    
    respond_to do |format|
      redirect_to(request.env['HTTP_REFERER'])
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: "Department was successfully updated." }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_department
    @department = Department.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def department_params
    params.require(:department).permit(:guildstone_id, :title, :description, :parent_department_id, :department_type)
  end



end