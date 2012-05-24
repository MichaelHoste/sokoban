class CreateLevelUserLinks < ActiveRecord::Migration
  def change
    create_table :level_user_links do |t|
      t.integer :id
      t.integer :user_id
      t.integer :level_id
      t.text    :uncompressed_path
      t.text    :compressed_path
      t.integer :pushes
      t.integer :moves

      t.timestamps
    end
  end
end
