class StatisticsController < ApplicationController
  def index
    @number_of_images = Image.count
    @number_of_days = Image.number_of_days
    @image_stats = Image.group("DATE(taken_at)").order('DATE(taken_at) DESC').count
  end
end
