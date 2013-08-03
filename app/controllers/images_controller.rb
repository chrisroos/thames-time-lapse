class ImagesController < ApplicationController
  def index
    redirect_to image_path(Image.latest)
  end

  def show
    @image = Image.find(params[:id])
  end
end
