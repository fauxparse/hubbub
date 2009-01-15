class Project < ActiveRecord::Base
  belongs_to :company

  validates_presence_of :name
  include Statefulness
  
  alias_attribute :to_s, :name
  
  def to_param
    "#{id}_#{name.parameterize}"
  end
end
