class TaskNameText < ActiveRecord::Migration
  def self.up
    change_column :tasks, :name, :text
  end

  def self.down
    change_column :tasks, :name, :string
  end
end
