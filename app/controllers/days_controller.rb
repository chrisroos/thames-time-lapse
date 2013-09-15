class DaysController < ApplicationController
  def show
    page = params[:page] || 1
    @date = Date.parse(params[:date])
    @images = Image.taken_on(@date).order(:taken_at).page(page).per(24)
  end
end
