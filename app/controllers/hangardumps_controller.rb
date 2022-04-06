class HangardumpsController < ApplicationController
  def index
    @hangardumps = Hangardump.all
  end

  def new
    @hangardump = Hangardump.new
  end

  def create
    @hangardump = Hangardump.new(hangardump_params)
    if @hangardump.save
      redirect_to hangardumps_path, notice: "The hangardump has been uploaded."
    else
      render "new"
    end
  end

  def destroy
    @hangardump = Hangardump.find(params[:id])
    @hangardump.destroy
      redirect_to hangardumps_path, notice:  "The hangardump has been deleted."
  end

  private
    def hangardump_params
    params.require(:hangardump).permit(:name, attachment: [])
  end
end
