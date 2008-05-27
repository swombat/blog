class AddHitCountToArticles < ActiveRecord::Migration
  def self.up
    add_column :contents, :hit_count, :integer
  end

  def self.down
    remove_column :contents, :hit_count
  end
end
