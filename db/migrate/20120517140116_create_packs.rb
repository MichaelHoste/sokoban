class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.string  :name
      t.string  :file_name
      t.text    :description
      t.string  :email
      t.string  :url
      t.string  :copyright
      t.integer :max_width
      t.integer :max_height

      t.timestamps
    end
  end
end
