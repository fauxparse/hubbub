class User < ActiveRecord::Base
  acts_as_authentic :scope => :account_id
  belongs_to :account
  
  alias_attribute :to_s, :name
  alias_attribute :to_param, :login

  validates_presence_of :name
  validates_uniqueness_of :display_name, :scope => :account_id

  def display_name
    (s = super).blank? ? name : s
  end
end
