class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.belongs_to :company
      t.string :name
      t.text :description
      t.string :current_state
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
