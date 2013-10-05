class DaysController < ApplicationController
  def index
    redirect_to day_path(Date.today)
  end

  def show
    @date = Date.parse(params[:id])
    @previous_day = @date - 1
    @next_day = @date + 1
    @images = Image.per_hour(params[:id])
  end
end
