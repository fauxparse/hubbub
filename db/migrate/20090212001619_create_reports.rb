class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :name
      t.belongs_to :agency
      t.belongs_to :user
      t.belongs_to :company
      t.belongs_to :project
      t.date :starts_on
      t.date :ends_on
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
