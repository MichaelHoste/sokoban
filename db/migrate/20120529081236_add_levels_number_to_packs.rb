class AddLevelsNumberToPacks < ActiveRecord::Migration
  def up
    add_column :packs, :levels_count, :integer, :default => 0

    Pack.reset_column_information
    Pack.select(:id).find_each do |pack|
      Pack.reset_counters pack.id, :levels
    end
  end

  def down
    remove_column :packs, :levels_count
  end
end
