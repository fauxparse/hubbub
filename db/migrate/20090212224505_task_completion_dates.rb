class TaskCompletionDates < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.date :completed_on
    end

    change_table :assignments do |t|
      t.date :completed_on
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :completed_on
    end

    change_table :assignments do |t|
      t.remove :completed_on
    end
  end
end
