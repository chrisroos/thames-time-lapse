class DaysController < ApplicationController
  def show
    @date = Date.parse(params[:date])
    @images = Image.per_hour(params[:date])
  end
end
