class ImagesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        page = params[:page] || 1
        @images = Image.order('taken_at DESC').page(page).per(12)
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
