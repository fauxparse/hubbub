class User < ActiveRecord::Base
  acts_as_authentic
  belongs_to :account
  belongs_to :company
  has_and_belongs_to_many :roles, :uniq => true
  has_many :project_roles, :dependent => :nullify
  has_many :assignments
  has_many :blockages
  has_many :blocked_assignments, :through => :blockages, :source => :assignment
  has_attached_file :avatar,
    :styles => { :thumbnail => "64x64#", :tiny => "32x32#" },
    :default_url => "/images/default-user-:style.png",
    :path => ":rails_root/public/images/:attachment/:id/:style.:extension",
    :url => "/images/:attachment/:id/:style.:extension"
  
  alias_attribute :to_s, :display_name
  alias_attribute :to_param, :login
  validates_format_of :login, :with => /^[a-z0-9_]+$/i, :message => "may only contain letters, numbers and underscores"

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
  
  def agency_user?
    company.is_a?(Agency)
  end
end
