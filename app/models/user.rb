class User < ActiveRecord::Base
  acts_as_authentic :scope => :account_id
  belongs_to :account
  
  alias_attribute :to_s, :name
  alias_attribute :to_param, :login
end
