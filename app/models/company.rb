class Company < ActiveRecord::Base
  belongs_to :account
  
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug, :scope => :account_id
  before_validation :generate_slug
  
  alias_attribute :to_s, :name
  alias_attribute :to_param, :slug

protected
  def generate_slug
    self.slug = self.name.parameterize if self.slug.blank? && attribute_present?("name")
  end
end
