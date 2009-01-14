class Company < ActiveRecord::Base
  belongs_to :account
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :account_id
  
  alias_attribute :to_s, :name
end
