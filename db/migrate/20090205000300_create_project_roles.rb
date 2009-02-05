class CreateProjectRoles < ActiveRecord::Migration
  def self.up
    create_table :project_roles do |t|
      t.belongs_to :project
      t.belongs_to :role
      t.belongs_to :user
      t.integer :position
    end
  end

  def self.down
    drop_table :project_roles
  end
end
