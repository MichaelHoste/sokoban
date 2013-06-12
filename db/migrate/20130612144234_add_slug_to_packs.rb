class AddSlugToPacks < ActiveRecord::Migration
  def change
    add_column :packs, :slug, :string
    add_index  :packs, :slug

    Pack.reset_column_information

    Pack.all.each do |pack|
      pack.save!
    end
  end
end
