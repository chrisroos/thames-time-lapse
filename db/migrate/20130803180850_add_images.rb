class AddImages < ActiveRecord::Migration
  def change
    create_table :images, :force => true do |t|
      t.text :s3_key, null: false
      t.text :url, null: false
      t.timestamps
    end

    add_index :images, :s3_key, unique: true
  end
end
