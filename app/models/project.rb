class Project < ActiveRecord::Base
  belongs_to :company
  has_many :task_lists
  has_many :project_roles, :dependent => :destroy
  accepts_nested_attributes_for :project_roles, :allow_destroy => true, :reject_if => lambda { |p| p['role_id'].blank? }
  has_many :users, :through => :project_roles, :uniq => true
  delegate :agency, :to => :company
  
  validates_presence_of :name
  include Statefulness
  
  alias_attribute :to_s, :name
  
  named_scope :for_agency, lambda { |agency| { :include => { :company => :account }, :conditions => [ "projects.company_id = ? OR accounts.agency_id = ?", agency.id, agency.id ] } }
  
  def to_param
    "#{id}_#{name.parameterize}"
  end
  
  def project_role=(value)
    # ignore value from form
  end
end
