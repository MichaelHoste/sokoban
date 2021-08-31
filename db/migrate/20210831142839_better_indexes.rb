class BetterIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :level_user_links, :level_id
    add_index    :level_user_links, [:level_id, :best_level_user_score, :pushes, :moves, :created_at], :name => "optimized_indexes"
  end
end
