class ImagesController < ApplicationController
  def index
    if image = Image.latest
      redirect_to image_path(image)
    else
      render text: 'No images found'
    end
  end

  def show
    @image = Image.find(params[:id])
  end
end
