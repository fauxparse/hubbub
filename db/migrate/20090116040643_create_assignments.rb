class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.belongs_to :user
      t.belongs_to :task
      t.belongs_to :role
      t.text :description
      t.string :current_state
      t.integer :estimated_minutes
      t.integer :billable_minutes
      t.integer :total_minutes
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
