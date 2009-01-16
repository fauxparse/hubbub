class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :task
  has_many :blockages
  has_many :blocked_users, :through => :blockages, :source => :user
  
  include Statefulness
end
