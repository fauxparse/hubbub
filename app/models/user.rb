class User < ActiveRecord::Base
  acts_as_authentic :scope => :account_id
  belongs_to :account
  belongs_to :company
  has_and_belongs_to_many :roles, :uniq => true
  has_many :project_roles, :dependent => :nullify
  has_many :assignments
  has_many :blockages
  has_many :blocked_assignments, :through => :blockages, :source => :assignment
  has_attached_file :avatar, :styles => { :thumbnail => "64x64#" }, :default_url => "/images/default-user-:style.png"
  
  alias_attribute :to_s, :display_name
  alias_attribute :to_param, :login

  validates_presence_of :name, :email
  validates_uniqueness_of :display_name, :scope => :account_id
  
  def <=>(another)
    display_name <=> another.display_name
  end
  
  def display_name
    (s = super).blank? ? name : s
  end
  
  def name
    (s = super).blank? ? login.titleize : s
  end
  
  def has_role?(role)
    roles.include? Role[role]
  end
  
  def grant!(role)
    roles << Role[role]
    save(false)
  end
end
