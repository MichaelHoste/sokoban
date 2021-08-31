class AddComplexityToLevels < ActiveRecord::Migration
  def change
    add_column :levels, :complexity, :integer, :default => 0, :after => :pusher_pos_n

    add_index :levels, :complexity

    Level.reset_column_information

    Level.all.each do |level|
      level.update!({ :complexity => level.width * level.height * level.boxes_number })
    end
  end
end
