class AnybodyTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :anybody, :boolean, :default => false
  end

  def self.down
    remove_column :tasks, :anybody
  end
end
