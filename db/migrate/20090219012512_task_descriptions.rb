class TaskDescriptions < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.text :description
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :description
    end
  end
end
