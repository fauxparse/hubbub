class Account < ActiveRecord::Base
  has_many :users
  authenticates_many :user_sessions

  validates_presence_of :name
  validates_presence_of :subdomain
  validates_format_of :subdomain, :with => /^[A-Za-z0-9-]+$/, :message => 'The subdomain can only contain alphanumeric characters and dashes.', :allow_blank => true
  validates_uniqueness_of :subdomain, :case_sensitive => false
  validates_exclusion_of :subdomain, :in => %w( support blog www billing help api ), :message => "The subdomain <strong>{{value}}</strong> is reserved and unavailable."
  
  before_validation :properly_format_subdomain

protected
  def properly_format_subdomain
    self.subdomain = self.name if self.subdomain.blank? && attribute_present?("name")
    self.subdomain = self.subdomain.parameterize if attribute_present?("subdomain")
  end
end
