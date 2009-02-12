class TimeSliceSanity < ActiveRecord::Migration
  def self.up
    change_table :time_slices do |t|
      t.belongs_to :task
      t.belongs_to :project
      t.belongs_to :company
    end
    
    TimeSlice.all(:include => :activity).each do |t|
      t.task_id = t.activity.task.id
      t.project_id = t.activity.project.id
      t.company_id = t.activity.company.id
      t.save
    end
    
    change_table :time_slices do |t|
      t.remove :activity_type
      t.remove :activity_id
    end
  end

  def self.down
    change_table :time_slices do |t|
      t.string :activity_type
      t.integer :activity_id
    end

    TimeSlice.all(:include => :activity).each do |t|
      t.activity_id = t.task.id
      t.activity_type = "Task"
      t.save
    end
  end
end
