class StatisticsController < ApplicationController
  def index
    @image_stats = Image.group("DATE(taken_at)").count
  end
end
