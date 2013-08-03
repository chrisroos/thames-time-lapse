class AddTakenAtToImages < ActiveRecord::Migration
  class Image < ActiveRecord::Base
  end

  def up
    add_column :images, :taken_at, :datetime

    Image.all.each do |image|
      taken_at = DateTime.parse(image.s3_key[/imageSequence_(\d+).jpg/, 1])
      image.update_attributes!(taken_at: taken_at)
    end

    change_column :images, :taken_at, :datetime, null: false
  end

  def down
    remove_column :images, :taken_at
  end
end
