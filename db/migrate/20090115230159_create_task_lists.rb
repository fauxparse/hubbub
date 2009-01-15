class CreateTaskLists < ActiveRecord::Migration
  def self.up
    create_table :task_lists do |t|
      t.belongs_to :project
      t.string :name
      t.text :description
      t.string :current_state
      t.integer :open_tasks_count, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :task_lists
  end
end
