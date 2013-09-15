class StatisticsController < ApplicationController
  def index
    @image_stats = Image.group("DATE(taken_at)").order('DATE(taken_at) DESC').count
  end
end
