class CounterCaches < ActiveRecord::Migration
  def self.up
    add_column :tasks, :assignments_count, :integer, :default => 0
    add_column :assignments, :blockages_count, :integer, :default => 0
  end

  def self.down
    remove_column :tasks, :assignments_count
    remove_column :assignments, :blockages_count
  end
end
