class ImagesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        if image = Image.latest
          redirect_to image_path(image)
        else
          render text: 'No images found'
        end
      end
      format.atom do
        @images = Image.most_recent(10)
      end
    end
  end

  def show
    @image = Image.find(params[:id])
  end
end
