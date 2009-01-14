class UserCompanies < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.belongs_to :company
    end
    add_index :users, :company_id
  end

  def self.down
    remove_index :users, :company_id
    remove_column :users, :company_id
  end
end
