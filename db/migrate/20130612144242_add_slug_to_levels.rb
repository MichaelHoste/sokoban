class AddSlugToLevels < ActiveRecord::Migration
  def change
    add_column :levels, :slug, :string
    add_index  :levels, :slug

    Level.reset_column_information

    Level.all.each do |level|
      level.save!
    end
  end
end
