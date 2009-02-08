class TaskDueDates < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.date :due_on
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :due_on
    end
  end
end
