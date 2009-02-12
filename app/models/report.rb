class Report < ActiveRecord::Base
  belongs_to :agency
  belongs_to :user
  belongs_to :company
  belongs_to :project
  belongs_to :task
  
  def times
    TimeSlice.for_user(user).for_company(company).for_project(project).for_task(task).from_date(starts_on).until_date(ends_on).all(:include => [ :user, :company, :project, :task ])
  end
end
