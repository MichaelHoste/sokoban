class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.integer :id
      t.integer :pack_id
      t.string  :name
      t.integer :width
      t.integer :height
      t.string  :copryright
      t.text    :grid
      t.integer :box_count
      t.integer :goal_count
      t.integer :pusher_pos_m
      t.integer :pusher_pos_n

      t.timestamps
    end
  end
end
