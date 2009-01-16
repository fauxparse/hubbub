class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.belongs_to :task_list
      t.string :name
      t.string :current_state
      t.boolean :billable
      t.boolean :visible_to_client
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
