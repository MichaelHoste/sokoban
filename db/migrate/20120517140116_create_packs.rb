class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.integer :id
      t.string :title
      t.string :description
      t.string :email
      t.string :url
      t.string :copyright
      t.integer :max_width
      t.integer :max_height

      t.timestamps
    end
  end
end
