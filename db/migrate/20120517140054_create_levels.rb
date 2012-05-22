class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.integer :id
      t.integer :pack_id
      t.string  :name
      t.integer :width
      t.integer :height
      t.string  :copyright
      t.text    :grid
      t.text    :grid_with_floor
      t.integer :boxes_number
      t.integer :goals_number
      t.integer :pusher_pos_m
      t.integer :pusher_pos_n

      t.timestamps
    end
  end
end
