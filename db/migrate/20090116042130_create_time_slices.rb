class CreateTimeSlices < ActiveRecord::Migration
  def self.up
    create_table :time_slices do |t|
      t.belongs_to :activity, :polymorphic => true
      t.belongs_to :user
      t.text :summary
      t.date :date
      t.boolean :billable
      t.integer :minutes
    end
  end

  def self.down
    drop_table :time_slices
  end
end
