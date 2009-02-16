class Sortability < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.integer :position
    end

    change_table :task_lists do |t|
      t.integer :position
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :position
    end

    change_table :task_lists do |t|
      t.remove :position
    end
  end
end
