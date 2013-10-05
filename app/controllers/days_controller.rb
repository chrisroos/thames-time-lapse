class DaysController < ApplicationController
  def index
    redirect_to day_path(Date.today)
  end

  def show
    @date = Date.parse(params[:date])
    @images = Image.per_hour(params[:date])
  end
end
