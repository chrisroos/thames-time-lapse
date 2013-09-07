atom_feed do |feed|
  feed.title("Most recent images from thames-time-lapse")
  feed.updated(@images.first.taken_at)

  @images.each do |image|
    feed.entry(image) do |entry|
      entry.content type: 'html' do |html|
        html.img src: image.url
      end
    end
  end
end
