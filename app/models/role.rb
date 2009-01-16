class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :uniq => true
  
  validates_presence_of :name
  validates_format_of :name, :with => /[a-z0-9_]+/
  validates_uniqueness_of :name

  def to_sym
    name.blank? ? nil : name.to_sym
  end
  
  def name=(value)
    super(value && self.class.normalize_name(value))
  end
  
  class << self
    def [](role)
      role.is_a?(Role) ? role : find_or_initialize_by_name(normalize_name(role))
    end
    
    def normalize_name(name)
      name.to_s.underscore.gsub /[^a-z0-9]+/, "_"
    end
  end
end
